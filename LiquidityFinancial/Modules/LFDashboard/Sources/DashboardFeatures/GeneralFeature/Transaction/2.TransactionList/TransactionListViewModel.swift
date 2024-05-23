import Foundation
import Factory
import AccountData
import AccountDomain
import LFUtilities
import SolidData
import SolidDomain

@MainActor
public class TransactionListViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
    
  lazy var getCardTransactionsUseCase: SolidGetCardTransactionsUseCaseProtocol = {
    SolidGetCardTransactionsUseCase(repository: solidCardRepository)
  }()
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  @Published var transactions: [TransactionModel] = []
  @Published var transactionDetail: TransactionModel?
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var searchText = ""
  @Published var toastMessage: String?

  let filterType: FilterType
  let cardID: String
  let currencyType: String
  let contractAddress: String?
  let transactionTypes: [String]
  
  private var offset = 0
  private var total = 0
  private var limit = 20
  
  public init(
    filterType: FilterType,
    currencyType: String,
    contractAddress: String?,
    cardID: String,
    transactionTypes: [String]
  ) {
    self.filterType = filterType
    self.currencyType = currencyType
    self.contractAddress = contractAddress
    self.cardID = cardID
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
      await loadTransactions(offset: Constants.transactionOffset)
    }
  }
  
  func loadMoreIfNeccessary(transaction: TransactionModel) {
    guard
      let lastObject = transactions.last,
      lastObject.id == transaction.id && !isLoadingMore,
      total > 0,
      total != transactions.count
    else {
      return
    }
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
    switch filterType {
    case .account:
      await loadAccountTransactions(offset: offset)
    case .card:
      await loadCardTransactions(offset: offset)
    }
  }
  
  func loadAccountTransactions(offset: Int) async {
    do {
      let parameters = APITransactionsParameters(
        currencyType: currencyType,
        transactionTypes: transactionTypes,
        limit: limit,
        offset: offset,
        contractAddress: contractAddress?.nilIfEmpty
      )
      
      let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
      self.total = transactions.total
      self.transactions += transactions.data.compactMap({ TransactionModel(from: $0) })
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
  
  func loadCardTransactions(offset: Int) async {
    do {
      let parameters = APISolidCardTransactionsParameters(
        cardId: cardID,
        currencyType: Constants.CurrencyType.fiat.rawValue,
        transactionTypes: Constants.transactionsTypes,
        limit: limit,
        offset: offset
      )
      let transactions = try await getCardTransactionsUseCase.execute(parameters: parameters)
      
      self.total = transactions.total
      self.transactions += transactions.data.compactMap({ TransactionModel(from: $0) })
    } catch {
      log.error(error.userFriendlyMessage)
      toastMessage = error.userFriendlyMessage
    }
  }
}

extension TransactionListViewModel {
  public enum FilterType {
    case account
    case card
  }
}
