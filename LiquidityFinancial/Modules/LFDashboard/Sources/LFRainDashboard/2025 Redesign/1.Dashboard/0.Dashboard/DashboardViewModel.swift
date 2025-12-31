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
import LFStyleGuide
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalService) var portalService
  @LazyInjected(\.rainRepository) var rainRepository

  @Published var isLoading: Bool = false
  @Published var activity = Activity.loading
  @Published var bottomSheet: BottomSheet?
  @Published var navigation: Navigation?
  @Published var toastData: ToastData?
  
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
  
  // This is flag handle case when app have change scenePhase
  var shouldReloadListTransaction: Bool = false
  
  private let transactionLimitEntity: Int = 20
  private let transactionLimitOffset: Int = 0
  // Set when all data is beign refreshed to avoid duplicate calls
  // and cancellation errors when using pull-to-refresh
  private var isRefreshingAllData: Bool = false
  
  private var cancellable: Set<AnyCancellable> = []
  
  init() {
    observeCollateralChanges()
    observeCreditBalancesChanges()
    handleEventReloadTransaction()
    
    getPortalAsset()
    
    Task {
      await onRefreshAllData(isAnimated: true)
    }
  }
}

// MARK: - Binding Observables
extension DashboardViewModel {
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
        
        Task {
          try await self.refreshTransaction(withAnimation: animation)
        }
      }
      .store(in: &cancellable)
  }
  
  func getPortalAsset() {
    portalStorage
      .cryptoAsset(with: AssetType.usdc.symbol ?? "N/A")
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

// MARK: Handle Interactions
extension DashboardViewModel {
  func onRefreshAllData(
    isAnimated: Bool
  ) async {
    // Only refresh all data once
    guard !isRefreshingAllData
    else {
      return
    }
    
    defer {
      isRefreshingAllData = false
      
      activity = transactions.isEmpty ? .addFunds : .transactions
      isLoading = false
    }
    
    isRefreshingAllData = true
    
    if isAnimated {
      activity = .loading
      isLoading = true
    }
    
    do {
      let collateralResponse = try await getCollateralContractUseCase.execute()
      let creditBalancesResponse = try await getCreditBalanceUseCase.execute()
      
      try await loadTransactions()
      
      accountDataManager.storeCollateralContract(collateralResponse)
      accountDataManager.storeCreditBalances(creditBalancesResponse)
    } catch {
      toastData = ToastData(
        type: .error,
        title: error.userFriendlyMessage
      )
    }
  }
  
  func refreshTransaction(
    withAnimation: Bool
  ) async throws {
    // Don't refresh transaction when all data is being refreshed
    // because transactions are part of that method as well
    guard !isRefreshingAllData
    else {
      return
    }
    
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
      
      throw error
    }
  }
  
  func onTransactionItemTap(
    _ transaction: TransactionModel
  ) {
    Haptic.impact(.light).generate()
    
    navigation = .transactionDetail(transaction)
  }
  
  func onSeeAllTransactionsButton() {
    navigation = .transactions
  }
  
  func onAddFundsButtonTap() {
    guard let portalAsset = portalAsset
    else {
      toastData = ToastData(type: .error, title: L10N.Common.MoveCryptoInput.SendCollateral.errorMessage)
      bottomSheet = nil
      
      return
    }
    
    performDepositNavigation(type: .externalWallet, collateralAsset: portalAsset)
  }
  
  func onWithdrawFundsButtonTap() {
    //bottomSheet = .withdrawCollateral - Commenting out when removing internal wallet flows, will keep in case we wanna put it back in the future
    
    Task {
      guard let portalAsset = collateralAsset
      else {
        toastData = ToastData(type: .error, title: L10N.Common.MoveCryptoInput.SendCollateral.errorMessage)
        bottomSheet = nil
        
        return
      }
      
      await performWithdrawalNavigation(type: .externalWallet, collateralAsset: portalAsset)
    }
  }
}

// MARK: - Helpers
extension DashboardViewModel {
  func walletTypeButtonTapped(type: WalletType) {
    Task {
      // The asset object is pulled from portal wallet for deposits and collateral response for the withdrawals
      guard let portalAsset = (bottomSheet == .depositCollateral ? portalAsset : collateralAsset)
      else {
        toastData = ToastData(type: .error, title: L10N.Common.MoveCryptoInput.SendCollateral.errorMessage)
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
      navigation = .addToCard(
        title: collateralAsset.type?.symbol ?? .empty
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
  
  func openGetStartedURL() {
    if let url = URL(string: "https://www.avalanchecard.com") {
      openURL(url)
    }
  }
  
  func openURL(_ url: URL) {
    UIApplication.shared.open(url)
  }
}

// MARK: - APIs Handling
private extension DashboardViewModel {
  func loadTransactions() async throws {
    let transactionTypesFilter = filterConfiguration.transactionTypesFilter ?? Constants.TransactionTypesRequest.fiat.types
    let transactionCurrenciesFilter = filterConfiguration.transactionCurrenciesFilter
    
    let parameters = APITransactionsParameters(
      transactionTypes: transactionTypesFilter,
      limit: transactionLimitEntity,
      offset: transactionLimitOffset,
      currencies: transactionCurrenciesFilter
    )
    
    let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
    self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
  }
}

// MARK: - Enums
extension DashboardViewModel {
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
    case addToCard(title: String)
  }
}

// MARK: Structs
extension DashboardViewModel {
  struct TutorialResource: Identifiable {
    let id: String
    let icon: Image
    let title: String
    let subtitle: String
    let url: URL?
  }
  
  var tutorialResources: [TutorialResource] {
    [
      .init(
        id: "1",
        icon: GenImages.Images.icoWhatIsAvax.swiftUIImage,
        title: "AVALANCHE (AVAX)?",
        subtitle: "What is",
        url: URL(string: "https://www.avalanchecard.com")
      ),
      .init(
        id: "2",
        icon: GenImages.Images.icoHowToCreateWallet.swiftUIImage,
        title: "CREATE A WALLET?",
        subtitle: "How to",
        url: URL(string: "https://www.avalanchecard.com")
      ),
      .init(
        id: "3",
        icon: GenImages.Images.icoHowToGetCoin.swiftUIImage,
        title: "CREATE A WALLET?",
        subtitle: "How to",
        url: URL(string: "https://www.avalanchecard.com")
      )
    ]
  }
}
