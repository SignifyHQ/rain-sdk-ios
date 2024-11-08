import Foundation
import RainFeature
import RainDomain
import Factory
import NetSpendData
import NetspendDomain
import AccountDomain
import AccountData
import LFUtilities
import Combine
import GeneralFeature
import LFLocalizable
import Services

@MainActor
final class CashViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalService) var portalService
  @LazyInjected(\.rainRepository) var rainRepository

  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var isDisableView: Bool = false
  
  @Published var cashBalanceValue: Double = 0
  @Published var toastMessage: String?
  
  @Published var bottomSheet: BottomSheet?
  
  @Published var activity = Activity.loading
  
  @Published var selectedAsset: AssetType = .usd
  
  @Published var navigation: Navigation?
  
  @Published var transactions: [TransactionModel] = []
  @Published var assets: [AssetModel] = []
  @Published var portalAsset: AssetModel?
  @Published var collateralAsset: AssetModel?
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var fullScreen: FullScreen?
  
  lazy var getCollateralContractUseCase: GetCollateralUseCaseProtocol = {
    GetCollateralUseCase(repository: rainRepository)
  }()
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  //This is flag handle case when app have change scenePhase
  var shouldReloadListTransaction: Bool = false
  
  var transactionLimitEntity: Int {
    20
  }
  
  var transactionLimitOffset: Int {
    0
  }

  private(set) var addFundsViewModel = AddFundsViewModel()
  
  private var cancellable: Set<AnyCancellable> = []
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepository: DashboardRepository) {
    self.dashboardRepository = dashboardRepository
    
    dashboardRepository
      .$fiatData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] fiatData in
        if fiatData.loading {
          self?.assets = fiatData.fiatAccount.map {
            AssetModel(
              id: $0.id,
              type: AssetType(rawValue: $0.currency.rawValue.uppercased()),
              availableBalance: $0.availableBalance,
              availableUsdBalance: $0.availableUsdBalance,
              externalAccountId: $0.externalAccountId
            )
          }
          if let account = fiatData.fiatAccount.first {
            self?.accountDataManager.fiatAccountID = account.id
            self?.accountDataManager.externalAccountID = account.externalAccountId
            self?.selectedAsset = AssetType(rawValue: account.currency.rawValue.uppercased()) ?? .usd
            self?.firstLoadData()
          }
        }
      }
      .store(in: &cancellable)
    
    observeCollateralChanges()
    subscribeLinkedSources()
    handleEventReloadTransaction()
    
    getPortalAsset()
    refreshCollateralData()
  }
  
  func subscribeLinkedSources() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else { return }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
  
  func observeCollateralChanges() {
    accountDataManager
      .collateralContractSubject
      .map { [weak self] rainCollateral in
        self?.cashBalanceValue = rainCollateral?.creditLimit ?? 0.0
        
        return rainCollateral?
          .tokensEntity
          .compactMap { rainToken in
            AssetModel(rainCollateralAsset: rainToken)
          }
          .first(
            where: { asset in
              asset.type == .usdc
            }
          )
      }
      .assign(to: &$collateralAsset)
  }
  
  func handleEventReloadTransaction() {
    NotificationCenter.default.publisher(for: .moneyTransactionSuccess)
      .sink { [weak self] _ in
        guard let self else { return }
        let animation = self.transactions.isEmpty ? true : false
        self.refreshTransaction(withAnimation: animation)
      }
      .store(in: &cancellable)
  }
  
  func onRefresh() {
    refreshCards()
    refreshCollateralData()
  }
  
  private func refreshCards() {
    Task { @MainActor in
      await dashboardRepository.fetchRainAccount()
      
      guard activity != .loading else { return }
      refreshTransaction(withAnimation: true)
      NotificationCenter.default.post(name: .refreshListCards, object: nil)
    }
  }
  
  private func refreshCollateralData() {
    Task { @MainActor in
      isLoading = true
      defer {
        isLoading = false
      }
      
      let response = try await getCollateralContractUseCase.execute()
      accountDataManager.storeCollateralContract(response)
    }
  }
  
  func firstLoadData() {
    guard transactions.isEmpty else { return }
    
    Task { @MainActor in
      do {
        activity = .loading
        try await loadTransactions()
        activity = transactions.isEmpty ? .addFunds : .transactions
      } catch {
        activity = .addFunds
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func refreshTransaction(withAnimation: Bool) {
    Task { @MainActor in
      do {
        if withAnimation {
          activity = .loading
        }
        try await loadTransactions()
        if withAnimation {
          activity = transactions.isEmpty ? .addFunds : .transactions
        }
      } catch {
        if withAnimation {
          activity = .addFunds
        }
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
}

// MARK: - View Helpers
extension CashViewModel {
  func handleFundingAcceptAgreement(isAccept: Bool) {
    if isAccept {
      addFundsViewModel.goNextNavigation()
    } else {
      addFundsViewModel.stopAction()
    }
  }
  
  func onClickedChangeAssetButton() {
    navigation = .changeAsset
  }
  
  func addMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.receive)
    } else {
      navigation = .moveMoney(kind: .receive)
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.send)
    } else {
      navigation = .moveMoney(kind: .send)
    }
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func guestCardTapped() {
    
  }
  
  func addToBalanceButtonTapped() {
    bottomSheet = .depositCollateral
  }
  
  func withdrawBalanceButtonTapped() {
    bottomSheet = .withdrawCollateral
  }
  
  func walletTypeButtonTapped(type: WalletType) {
    Task {
      // The asset object is pulled from portal wallet for deposits and collateral response for the withdrawals
      guard let portalAsset = (bottomSheet == .depositCollateral ? portalAsset : collateralAsset)
      else {
        toastMessage = L10N.Common.MoveCryptoInput.SendCollateral.errorMessage
        bottomSheet = nil
        
        return
      }
      
      switch bottomSheet {
      case .depositCollateral:
        performDepositNavigation(type: type, collateralAsset: portalAsset)
      case .withdrawCollateral:
        await performWithdrawalNavigation(type: type, collateralAsset: portalAsset)
      default:
        break
      }
    }
  }
  
  func performDepositNavigation(type: WalletType, collateralAsset: AssetModel) {
    bottomSheet = nil
    switch type {
    case .internalWallet:
      navigation = .enterDepositAmount(assetCollateral: collateralAsset)
    case .externalWallet:
      guard let collateralContract = accountDataManager.collateralContract else {
        toastMessage = L10N.Common.MoveCryptoInput.NoCollateralContract.errorMessage
        return
      }
      navigation = .depositWalletAddress(
        title: collateralAsset.type?.title ?? .empty,
        address: collateralContract.address
      )
    }
  }
  
  func performWithdrawalNavigation(type: WalletType, collateralAsset: AssetModel) async {
    bottomSheet = nil
    switch type {
    case .internalWallet:
      guard let myUSDCWalletAddress = await portalService.getWalletAddress(), !myUSDCWalletAddress.isEmpty else {
        return
      }
      navigation = .enterWithdrawalAmount(address: myUSDCWalletAddress, assetCollateral: collateralAsset)
    case .externalWallet:
      navigation = .enterWalletAddress(assetCollateral: collateralAsset)
    }
  }
}

// MARK: - Private Functions
private extension CashViewModel {
  func loadTransactions() async throws {
    let parameters = APITransactionsParameters(
      currencyType: currencyType,
      transactionTypes: Constants.TransactionTypesRequest.fiat.types,
      limit: transactionLimitEntity,
      offset: transactionLimitOffset
    )
    let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
    self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
  }
  
  func getPortalAsset() {
    portalStorage
      .cryptoAsset(with: AssetType.usdc.title)
      .receive(on: DispatchQueue.main)
      .map { asset in
        guard let asset
        else {
          return nil
        }
        
        return AssetModel(portalAsset: asset)
      }
      .assign(to: &$portalAsset)
  }
}

// MARK: - Types
extension CashViewModel {
  enum Activity {
    case loading
    case addFunds
    case transactions
  }
  
  enum BottomSheet: Identifiable {
    case depositCollateral
    case withdrawCollateral
    
    var id: String {
      switch self {
      case .depositCollateral:
        return "depositCollateral"
      case .withdrawCollateral:
        return "withdrawCollateral"
      }
    }
    
    var title: String {
      switch self {
      case .depositCollateral:
        return L10N.Common.CashTab.DepositBalance.sheetTitle
      case .withdrawCollateral:
        return L10N.Common.CashTab.WithdrawBalance.sheetTitle
      }
    }
  }
  
  enum Navigation {
    case changeAsset
    case transactions
    case transactionDetail(TransactionModel)
    case moveMoney(kind: MoveMoneyAccountViewModel.Kind)
    case enterDepositAmount(assetCollateral: AssetModel)
    case enterWithdrawalAmount(address: String, assetCollateral: AssetModel)
    case enterWalletAddress(assetCollateral: AssetModel)
    case depositWalletAddress(title: String, address: String)
  }
  
  enum FullScreen: Identifiable {
    case fundCard(MoveMoneyAccountViewModel.Kind)

    var id: String {
      switch self {
      case .fundCard: return "fundCard"
      }
    }
  }
}
