import Foundation

@MainActor
class TransactionListViewModel: ObservableObject {
  let type: Kind
  private var offset = 0
  private var total = 0

  @Published var transactions: [TransactionModel] = [
    TransactionModel.generateTestData(),
    TransactionModel.generateTestData(),
    TransactionModel.generateTestData(),
    TransactionModel.generateTestData(),
    TransactionModel.generateTestData()
  ]
  @Published var transactionDetail: TransactionModel?
  @Published var showIndicator = false
  @Published var searchText = ""

  init(type: Kind) {
    self.type = type
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
  }

  func loadMoreIfNeccessary(transaction: TransactionModel) {
    guard
      let lastObject = transactions.last,
      lastObject.id == transaction.id
    else {
      return
    }
  }

  func selectedTransaction(_ transaction: TransactionModel) {
    transactionDetail = transaction
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
