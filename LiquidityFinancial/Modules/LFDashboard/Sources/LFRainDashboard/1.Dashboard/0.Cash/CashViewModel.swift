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

  @Published var isLoading: Bool = false
  @Published var activity = Activity.loading
  @Published var bottomSheet: BottomSheet?
  @Published var navigation: Navigation?
  @Published var toastMessage: String?
  
  @Published var filterConfiguration: TransactionFilterConfiguration = TransactionFilterConfiguration()
  @Published var presentedFilterSheet: TransactionFilterButtonType?
  
  @Published var cashBalanceValue: Double = 0
  @Published var selectedAsset: AssetType = .usd
  @Published var portalAsset: AssetModel?
  @Published var collateralAsset: AssetModel?
  
  @Published var transactions: [TransactionModel] = []
  
  lazy var getCollateralContractUseCase: GetCollateralUseCaseProtocol = {
    GetCollateralUseCase(repository: rainRepository)
  }()
  
  lazy var getCreditBalanceUseCase: GetCreditBalanceUseCaseProtocol = {
    GetCreditBalanceUseCase(repository: rainRepository)
  }()
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  //This is flag handle case when app have change scenePhase
  var shouldReloadListTransaction: Bool = false
  
  private let transactionLimitEntity: Int = 20
  private let transactionLimitOffset: Int = 0
  
  private var cancellable: Set<AnyCancellable> = []
  
  init() {
    observeCollateralChanges()
    observeCreditBalancesChanges()
    
    handleEventReloadTransaction()
    
    refreshTransaction(withAnimation: true)
    getPortalAsset()
    refreshBalancesCollateralData()
  }
  
  func observeCollateralChanges() {
    accountDataManager
      .collateralContractSubject
      .map { rainCollateral in
        rainCollateral?
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
  
  func observeCreditBalancesChanges() {
    accountDataManager
      .creditBalancesSubject
      .map { creditBalances in
        creditBalances?.availableBalance ?? 0.0
      }
      .assign(to: &$cashBalanceValue)
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
    refreshTransaction(withAnimation: true)
    refreshBalancesCollateralData()
  }
  
  private func refreshBalancesCollateralData() {
    Task { @MainActor in
      isLoading = true
      defer {
        isLoading = false
      }
      
      let collateralResponse = try await getCollateralContractUseCase.execute()
      let creditBalancesResponse = try await getCreditBalanceUseCase.execute()
      
      accountDataManager.storeCollateralContract(collateralResponse)
      accountDataManager.storeCreditBalances(creditBalancesResponse)
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
  func transactionItemTapped(
    _ transaction: TransactionModel
  ) {
    Haptic.impact(.light).generate()
    
    navigation = .transactionDetail(transaction)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func addToBalanceButtonTapped() {
    //bottomSheet = .depositCollateral - Commenting out when removing internal wallet flows, will keep in case we wanna put it back in the future
    
    guard let portalAsset = portalAsset
    else {
      toastMessage = L10N.Common.MoveCryptoInput.SendCollateral.errorMessage
      bottomSheet = nil
      
      return
    }
    
    performDepositNavigation(type: .externalWallet, collateralAsset: portalAsset)
  }
  
  func withdrawBalanceButtonTapped() {
    //bottomSheet = .withdrawCollateral - Commenting out when removing internal wallet flows, will keep in case we wanna put it back in the future
    
    Task {
      guard let portalAsset = collateralAsset
      else {
        toastMessage = L10N.Common.MoveCryptoInput.SendCollateral.errorMessage
        bottomSheet = nil
        
        return
      }
      
      await performWithdrawalNavigation(type: .externalWallet, collateralAsset: portalAsset)
    }
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
    let transactionTypesFilter = filterConfiguration.transactionTypesFilter ?? Constants.TransactionTypesRequest.fiat.types
    let transactionCurrenciesFilter = filterConfiguration.transactionCurrenciesFilter
    
    let parameters = APITransactionsParameters(
      currencyType: currencyType,
      transactionTypes: transactionTypesFilter,
      limit: transactionLimitEntity,
      offset: transactionLimitOffset,
      contractAddress: transactionCurrenciesFilter
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
    case transactions
    case transactionDetail(TransactionModel)
    case enterDepositAmount(assetCollateral: AssetModel)
    case enterWithdrawalAmount(address: String, assetCollateral: AssetModel)
    case enterWalletAddress(assetCollateral: AssetModel)
    case depositWalletAddress(title: String, address: String)
  }
}
