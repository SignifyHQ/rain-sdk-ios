import Foundation
import LFUtilities
import LFLocalizable
import LFTransaction
import LFRewards
import AccountData
import AccountDomain
import Factory

@MainActor
class RewardViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var feed: DataStatus<TransactionModel> = .idle
  @Published var navigation: Navigation?
  @Published var account: LFAccount?
  @Published var toastMessage: String = ""
  
  private var isFirstLoad: Bool = false
  private var isLoading: Bool = false
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  init() {
    isFirstLoad = true
    subscribeToUserTransactionNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

  // MARK: - Actions

extension RewardViewModel {
  func refresh() {
    isFirstLoad = true
    apiRefreshData()
  }
  
  func onAppear() {
    guard !isLoading else { return }
    apiRefreshData()
  }
  
  func seeAllTransactionsTapped() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    navigation = .transactionDetail(transaction)
  }
}

  // MARK: - API logic

private extension RewardViewModel {
  func subscribeToUserTransactionNotifications() {
    
  }
  
  func apiRefreshData() {
    Task {
      do {
        defer { isLoading = false }
        isLoading = true
        
        if isFirstLoad {
          feed = .loading
          let accounts = try await accountRepository.getAccount(currencyType: currencyType)
          guard let account = accounts.first else {
            // reset state for first load
            isFirstLoad = false
            
            feed = .success([])
            return
          }
          
          self.account = account
          let models = try await apiFetchTransactions(accountId: account.id)
          feed = .success(models)
          
          // reset state for first load
          isFirstLoad = false
        } else {
          if let account = account {
            let models = try await apiFetchTransactions(accountId: account.id)
            feed = .success(models)
          } else {
            let accounts = try await accountRepository.getAccount(currencyType: currencyType)
            guard let account = accounts.first else { return }
            self.account = account
            let models = try await apiFetchTransactions(accountId: account.id)
            feed = .success(models)
          }
        }
      } catch {
        if isFirstLoad {
          feed = .failure(error)
          // reset state for first load
          isFirstLoad = false
        }
        log.error(error.localizedDescription)
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func apiFetchCryptoAccount() async throws -> [LFAccount] {
    return try await accountRepository.getAccount(currencyType: currencyType)
  }
  
  func apiFetchTransactions(accountId: String) async throws -> [TransactionModel] {
    let transactions = try await accountRepository.getTransactions(
      accountId: accountId,
      currencyType: currencyType,
      transactionTypes: Constants.TransactionTypesRequest.fiat.types,
      limit: 50,
      offset: 0
    )
    return transactions.data.compactMap({ TransactionModel(from: $0) })
  }
}

  // MARK: - Types

extension RewardViewModel {
  enum Navigation {
    case transactions
    case transactionDetail(TransactionModel)
  }
}
