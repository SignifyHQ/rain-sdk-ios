import Foundation
import Factory
import AccountData
import AccountDomain
import LFUtilities

@MainActor
public class TransactionListViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  @Published var transactions: [TransactionModel] = []
  @Published var transactionDetail: TransactionModel?
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var searchText = ""
  @Published var toastMessage: String?

  @Published var filterConfiguration: TransactionFilterConfiguration = TransactionFilterConfiguration()
  @Published var presentedFilterSheet: TransactionFilterButtonType?
  
  let cardID: String
  let currencyType: String
  let contractAddress: String?
  let transactionTypes: [String]
  
  private var offset = 0
  private var total = 0
  private var limit = 20
  
  public init(
    currencyType: String,
    contractAddress: String?,
    cardID: String,
    transactionTypes: [String]
  ) {
    self.currencyType = currencyType
    self.contractAddress = contractAddress
    self.cardID = cardID
    self.transactionTypes = transactionTypes
    self.loadInitialData()
  }
  
  var appliedFilters: [TransactionFilterButtonType: Int] {
    [
      .type: filterConfiguration.selectedTypes.count,
      .currency: filterConfiguration.selectedCurrencies.count
    ]
  }
  
  var filteredTransactions: [TransactionModel] {
    transactions.filter {
      guard !searchText.isEmpty
      else {
        return true
      }
      
      return ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
      || ($0.subtitle).localizedCaseInsensitiveContains(searchText)
      || ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
      || ($0.currency ?? "").localizedCaseInsensitiveContains(searchText)
      || ($0.type.rawValue).localizedCaseInsensitiveContains(searchText)
    }
  }
  
  func loadInitialData() {
    Task {
      defer {
        isLoading = false
      }
      isLoading = true
      
      offset = Constants.transactionOffset
      transactions.removeAll()
      
      await loadTransactions(offset: offset)
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
    await loadAccountTransactions(offset: offset)
  }
  
  func loadAccountTransactions(offset: Int) async {
    do {
      let transactionTypesFilter = filterConfiguration.transactionTypesFilter ?? Constants.TransactionTypesRequest.fiat.types
      let transactionCurrenciesFilter = filterConfiguration.transactionCurrenciesFilter
      
      let parameters = APITransactionsParameters(
        transactionTypes: transactionTypesFilter,
        limit: limit,
        offset: offset,
        currencies: transactionCurrenciesFilter
      )
      
      let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
      self.total = transactions.total
      self.transactions += transactions.data.compactMap({ TransactionModel(from: $0) })
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
}
