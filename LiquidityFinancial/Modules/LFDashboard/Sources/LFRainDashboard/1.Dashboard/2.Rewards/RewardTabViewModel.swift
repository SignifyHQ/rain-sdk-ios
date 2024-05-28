import Foundation
import AccountDomain
import AccountData
import LFUtilities
import Factory
import Combine
import AccountService
import GeneralFeature
import Services
import LFLocalizable

@MainActor
class RewardTabViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalService) var portalService
  
  @Published var isLoading: Bool = true
  @Published var showWithdrawalBalanceSheet: Bool = false
  @Published var rewardBalance: Double = 0
  @Published var toastMessage: String?
  
  @Published var selectedRewardCurrency: AssetType?
  @Published var navigation: Navigation?
  @Published var collateralAsset: AssetModel?
  @Published var activity = Activity.loading
  @Published var accounts: [AccountModel] = []
  @Published var transactions: [TransactionModel] = []
  @Published var availableRewardCurrencies: [AssetType] = []
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  var currencyType = Constants.CurrencyType.crypto.rawValue
  var transactionTypes = Constants.TransactionTypesRequest.rewardCryptoBack.types
  private var cancellable: Set<AnyCancellable> = []
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepo: DashboardRepository) {
    dashboardRepository = dashboardRepo
    dashboardRepository
      .$isLoadingRewardTab
      .receive(on: DispatchQueue.main)
      .assign(to: \.isLoading, on: self)
      .store(in: &cancellable)
    
    accountDataManager
      .availableRewardCurrenciesSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] rewardCurrencies in
        guard let self, let rewardCurrencies else { return }
        self.availableRewardCurrencies = rewardCurrencies.availableRewardCurrencies
          .compactMap { AssetType(rawValue: $0) }
          .sorted { $0.index < $1.index }
      }
      .store(in: &cancellable)
    
    accountDataManager
      .selectedRewardCurrencySubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] response in
        guard let self, let response else { return }
        self.selectedRewardCurrency = AssetType(rawValue: response.rewardCurrency)
        self.fetchAllTransactions()
      }
      .store(in: &cancellable)
    
    accountDataManager.accountsSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] accounts in
        self?.accounts = accounts
      }
      .store(in: &cancellable)
    
    getCollateralAsset()
  }
}

// MARK: - API Handle
extension RewardTabViewModel {
  func fetchAllTransactions() {
    Task { @MainActor in
      guard let selectedRewardCurrency else { return }
      if selectedRewardCurrency == .usd {
        currencyType = Constants.CurrencyType.fiat.rawValue
        transactionTypes = Constants.TransactionTypesRequest.rewardCashBack.types
      } else {
        currencyType = Constants.CurrencyType.crypto.rawValue
        transactionTypes = Constants.TransactionTypesRequest.rewardCryptoBack.types
      }
      await apiLoadTransactions(with: nil) // TODO: MinhNguyen - Will update it in the ENG-4319 ticket
    }
  }
  
  func apiLoadTransactions(with contractAddress: String?) async {
    do {
      let parameters = APITransactionsParameters(
        currencyType: currencyType,
        transactionTypes: transactionTypes,
        limit: Constants.shortTransactionLimit,
        offset: Constants.transactionOffset,
        contractAddress: contractAddress
      )
      let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
      self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
      activity = .transactions
    } catch {
      toastMessage = error.userFriendlyMessage
      if transactions.isEmpty {
        activity = .failure
      }
    }
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

// MARK: - View Helpers
extension RewardTabViewModel {
  func onClickedChangeReward() {
    navigation = .changeReward(selectedRewardCurrency: selectedRewardCurrency)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
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

extension RewardTabViewModel {
  enum Activity {
    case loading
    case failure
    case transactions
  }
  
  enum Navigation {
    case changeReward(selectedRewardCurrency: AssetType?)
    case transactions
    case transactionDetail(TransactionModel)
    case enterWithdrawalAmount(address: String, assetCollateral: AssetModel)
    case enterWalletAddress(assetCollateral: AssetModel)
  }
}
