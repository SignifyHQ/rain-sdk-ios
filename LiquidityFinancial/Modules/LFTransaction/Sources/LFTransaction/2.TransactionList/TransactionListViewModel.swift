import Foundation
import Factory
import AccountData
import AccountDomain
import LFUtilities

@MainActor
public class TransactionListViewModel: ObservableObject {
  
  private var offset = 0
  private var total = 0
  private var limit = 100
  
  @Published var transactions: [TransactionModel] = []
  @Published var transactionDetail: TransactionModel?
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var searchText = ""
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
    
  let type: Kind
  let currencyType: String
  let accountID: String
  let transactionTypes: String
  
  public init(type: Kind, currencyType: String, accountID: String, transactionTypes: String) {
    self.type = type
    self.currencyType = currencyType
    self.accountID = accountID
    self.transactionTypes = transactionTypes
    self.initData()
  }
  
  var filteredTransactions: [TransactionModel] {
    transactions.filter {
      searchText.isEmpty ? true : ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
    }
  }
  
  func initData() {
    Task {
      defer { isLoading = false }
      isLoading = true
      await loadTransactions(offset: 0)
    }
  }
  
  func loadMoreIfNeccessary(transaction: TransactionModel) {
    guard
      let lastObject = transactions.last,
      lastObject.id == transaction.id && !isLoadingMore
    else {
      return
    }
    if total <= 0 { return }
    let offset = transactions.count
    Task {
      defer { isLoadingMore = false }
      isLoadingMore = true
      await loadTransactions(offset: offset)
    }
  }
  
  func selectedTransaction(_ transaction: TransactionModel) {
    transactionDetail = transaction
  }
}

private extension TransactionListViewModel {
  func loadTransactions(offset: Int) async {
    do {
      if accountID.isEmpty { log.error("Missing account id") }
      let transactions = try await accountRepository.getTransactions(
        accountId: accountID,
        currencyType: currencyType,
        transactionTypes: transactionTypes,
        limit: limit,
        offset: offset
      )
      self.total = transactions.total
      self.transactions += transactions.data.compactMap({ TransactionModel(from: $0) })
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
}

extension TransactionListViewModel {
  public enum Kind {
    case cash
    case crypto
    case donations
    case cashback
  }
}
