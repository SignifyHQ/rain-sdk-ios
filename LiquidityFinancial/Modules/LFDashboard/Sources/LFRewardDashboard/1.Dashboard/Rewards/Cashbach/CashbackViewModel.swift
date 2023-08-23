import Foundation
import LFUtilities
import LFLocalizable
import LFTransaction
import LFRewards
import AccountData
import AccountDomain
import Factory

@MainActor
class CashbackViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var feed: DataStatus<TransactionModel> = .idle
  @Published var navigation: Navigation?
  @Published var sheet: Sheet?
  @Published var account: LFAccount?
  @Published var toastMessage: String = ""
  @Published var isLoading: Bool = false
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  init() {
    subscribeToUserTransactionNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

  // MARK: - Actions

extension CashbackViewModel {
  func refresh() {
    apiFetchCryptoAccount()
  }
  
  func seeAllTransactionsTapped() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    sheet = .transactionDetail(transaction)
  }
}

  // MARK: - API logic

extension CashbackViewModel {
  private func subscribeToUserTransactionNotifications() {
    
  }
  
  func apiFetchCryptoAccount() {
    Task {
      do {
        feed = .loading
        let accounts = try await accountRepository.getAccount(currencyType: currencyType)
        guard let account = accounts.first else {
          feed = .success([])
          return
        }
        self.account = account
        let models = try await apiFetchTransactions(accountId: account.id)
        feed = .success(models)
      } catch {
        feed = .failure(error)
        log.error(error.localizedDescription)
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func apiFetchTransactions(accountId: String) async throws -> [TransactionModel] {
    let transactions = try await accountRepository.getTransactions(
      accountId: accountId,
      currencyType: currencyType,
      transactionTypes: Constants.TransactionTypesRequest.normal.types,
      limit: 50,
      offset: 0
    )
    return transactions.data.compactMap({ TransactionModel(from: $0) })
  }
}

  // MARK: - Types

extension CashbackViewModel {
  enum Navigation {
    case transactions
  }
  
  enum Sheet: Identifiable {
    case transactionDetail(TransactionModel)
    
    var id: String {
      switch self {
      case let .transactionDetail(item):
        return "transactionDetail-\(item.id)"
      }
    }
  }
}
