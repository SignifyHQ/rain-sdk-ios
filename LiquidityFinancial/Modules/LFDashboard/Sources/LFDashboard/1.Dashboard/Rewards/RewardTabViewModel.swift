import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction
import Combine
import BaseDashboard

@MainActor
class RewardTabViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var selectedRewardCurrency: AssetType?
  @Published var toastMessage: String = ""
  @Published var isLoading: Bool = true
  @Published var accounts: [LFAccount] = []
  @Published var navigation: Navigation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  @Published var availableRewardCurrencies: [AssetType] = []
  
  var accountID: String = .empty
  var currencyType = Constants.CurrencyType.crypto.rawValue
  var transactionTypes = Constants.TransactionTypesRequest.rewardCryptoBack.types
  private var cancellable: Set<AnyCancellable> = []
  
  init(isLoading: Published<Bool>.Publisher) {
    isLoading
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
  }
}

// MARK: - View Helpers
extension RewardTabViewModel {
  
  func fetchAllTransactions() {
    Task { @MainActor in
      guard let selectedRewardCurrency else { return }
      accountID = accounts.first(where: { $0.currency == selectedRewardCurrency.rawValue })?.id ?? .empty
      if selectedRewardCurrency == .usd {
        currencyType = Constants.CurrencyType.fiat.rawValue
        transactionTypes = Constants.TransactionTypesRequest.rewardCashBack.types
      } else {
        currencyType = Constants.CurrencyType.crypto.rawValue
        transactionTypes = Constants.TransactionTypesRequest.rewardCryptoBack.types
      }
      await apiLoadTransactions()
    }
  }
  
  func apiLoadTransactions() async {
    guard !accountID.isEmpty else {
      activity = .failure
      return
    }
    do {
      let transactions = try await accountRepository.getTransactions(
        accountId: accountID,
        currencyType: currencyType,
        transactionTypes: transactionTypes,
        limit: 50,
        offset: 0
      )
      self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
      activity = .transactions
    } catch {
      toastMessage = error.localizedDescription
      if transactions.isEmpty {
        activity = .failure
      }
    }
  }
  
  func onClickedChangeReward() {
    navigation = .changeReward(selectedRewardCurrency: selectedRewardCurrency)
  }
  
  func onClickedSeeAllButton() {
    guard let selectedRewardCurrency else {
      return
    }
    navigation = .transactions(isCrypto: selectedRewardCurrency != .usd)
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
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
    case transactions(isCrypto: Bool)
    case transactionDetail(TransactionModel)
  }
}
