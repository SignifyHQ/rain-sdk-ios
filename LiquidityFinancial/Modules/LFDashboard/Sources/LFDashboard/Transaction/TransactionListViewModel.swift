import Foundation
import Factory
import AccountData
import AccountDomain
import LFUtilities

@MainActor
class TransactionListViewModel: ObservableObject {
  
  private var offset = 0
  private var total = 0
  private var limit = 50
  
  @Published var transactions: [TransactionModel] = []
  @Published var transactionDetail: TransactionModel?
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var searchText = ""
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  private var accountID: String {
    accountDataManager.accountID ?? ""
  }
  
  let type: Kind
  let currencyType: String
  
  init(type: Kind, currencyType: String ) {
    self.type = type
    self.currencyType = currencyType
  }
  
  var filteredTransactions: [TransactionModel] {
    transactions.filter {
      searchText.isEmpty ? true : ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
    }
  }
  
  var rowType: TransactionRowView.Kind {
    switch type {
    case .cash:
      return .cash
    case .crypto:
      return .crypto
    case .donations:
      return .userDonation
    case .cashback:
      return .userDonation
    }
  }
  
  func onAppear() {
    Task {
      defer { isLoading = false }
      isLoading = true
      await loadTransactions(offset: 0)
    }
  }
  
  func loadMoreIfNeccessary(transaction: TransactionModel) {
    guard
      let lastObject = transactions.last,
      lastObject.id == transaction.id
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
      let transactions = try await accountRepository.getTransactions(accountId: accountID, currencyType: currencyType, limit: limit, offset: offset)
      self.total = transactions.total
      self.transactions += transactions.data.compactMap({ TransactionModel(from: $0) })
    } catch {
      log.error(error.localizedDescription)
    }
  }
}

extension TransactionListViewModel {
  enum Kind {
    case cash
    case crypto
    case donations
    case cashback
  }
}
