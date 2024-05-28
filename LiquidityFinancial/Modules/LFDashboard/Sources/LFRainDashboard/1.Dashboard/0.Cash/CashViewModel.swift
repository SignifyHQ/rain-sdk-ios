import Foundation
import RainFeature
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

  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var isDisableView: Bool = false
  @Published var showWithdrawalBalanceSheet: Bool = false
  @Published var cashBalanceValue: Double = 0
  @Published var toastMessage: String?
  @Published var activity = Activity.loading
  @Published var selectedAsset: AssetType = .usd
  @Published var navigation: Navigation?
  @Published var transactions: [TransactionModel] = []
  @Published var assets: [AssetModel] = []
  @Published var collateralAsset: AssetModel?
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var fullScreen: FullScreen?
  
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
            self?.cashBalanceValue = account.availableBalance
            self?.selectedAsset = AssetType(rawValue: account.currency.rawValue.uppercased()) ?? .usd
            self?.firstLoadData()
          }
        }
        
        self?.isLoading = fiatData.loading
      }
      .store(in: &cancellable)
    
    subscribeLinkedSources()
    handleEventReloadTransaction()
    getCollateralAsset()
  }
  
  func subscribeLinkedSources() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else { return }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
    .store(in: &cancellable)
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
    Task { @MainActor in
      _ = try? await dashboardRepository.getRainAccount()
      dashboardRepository.fetchNetspendLinkedSources()
      
      guard activity != .loading else { return }
      refreshTransaction(withAnimation: true)
      NotificationCenter.default.post(name: .refreshListCards, object: nil)
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
    guard let collateralAsset else {
      toastMessage = L10N.Common.MoveCryptoInput.SendCollateral.errorMessage
      return
    }
    navigation = .addToBalance(assetCollateral: collateralAsset)
  }
  
  func withdrawBalanceButtonTapped() {
    showWithdrawalBalanceSheet = true
  }
  
  func walletTypeButtonTapped(type: WalletType) {
    Task {
      showWithdrawalBalanceSheet = false
      guard let collateralAsset else {
        toastMessage = L10N.Common.MoveCryptoInput.SendCollateral.errorMessage
        return
      }
      
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
  
  func getCollateralAsset() {
    portalStorage
      .cryptoAsset(with: AssetType.usdc.title)
      .receive(on: DispatchQueue.main)
      .map { asset in
        guard let asset else { return nil }
        return AssetModel(portalAsset: asset)
      }
      .assign(to: &$collateralAsset)
  }
}

// MARK: - Types
extension CashViewModel {
  enum Activity {
    case loading
    case addFunds
    case transactions
  }
  
  enum Navigation {
    case changeAsset
    case transactions
    case transactionDetail(TransactionModel)
    case moveMoney(kind: MoveMoneyAccountViewModel.Kind)
    case addToBalance(assetCollateral: AssetModel)
    case enterWithdrawalAmount(address: String, assetCollateral: AssetModel)
    case enterWalletAddress(assetCollateral: AssetModel)
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
