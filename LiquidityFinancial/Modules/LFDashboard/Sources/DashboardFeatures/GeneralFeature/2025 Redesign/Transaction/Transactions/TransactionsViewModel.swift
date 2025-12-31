import Foundation
import Factory
import AccountData
import AccountDomain
import LFUtilities

@MainActor
public class TransactionsViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  @Published var transactions: [TransactionModel] = [] {
    didSet {
      updateFilteredSection()
    }
  }
  @Published var transactionDetail: TransactionModel?
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var searchText = "" {
    didSet {
      updateFilteredSection()
    }
  }
  @Published var toastMessage: String?
  @Published var isShowingPurchasedCurrency: Bool = false
  @Published var filterConfiguration: TransactionsFilterConfiguration = TransactionsFilterConfiguration()
  @Published var presentedFilterSheet: TransactionsFilterButtonType?
  @Published var filteredTransactions: [TransactionSection] = []
  @Published var expandedSections: [String: Bool] = [:]
  
  var appliedFilters: [TransactionsFilterButtonType: Int] {
    [
      .type: filterConfiguration.selectedTypes.count,
      .currency: filterConfiguration.selectedCurrencies.count
    ]
  }
  
  let cardID: String
  let currencyType: String
  let contractAddress: String?
  let transactionTypes: [String]
  
  private var offset = 0
  private var total = 0
  private var limit = 20
  
  private var isFirstLoad: Bool = true
  
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
}

// MARK: Handle Interactions
extension TransactionsViewModel {
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
  
  func updateFilteredSection() {
    let filterdList = transactions.filter {
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
    filteredTransactions = groupByMonth(filterdList)
    
    // When the user first goes to this screen, the want the most recent month
    // to be expanded by default
    if isFirstLoad,
       filteredTransactions.count > 0 {
      isFirstLoad = false
      
      filteredTransactions[0].isExpanded = true
      expandedSections[filteredTransactions[0].month] = true
    }
  }
  
  func groupByMonth(_ list: [TransactionModel]) -> [TransactionSection] {
    let groups = Dictionary(grouping: list) { item -> String in
      let date = item.createdAtDate ?? .distantPast
      return LiquidityDateFormatter.monthYearAbbrev.parseToString(from: date)
    }
    
    return groups
      .map { (key, value) in
        let sortedItems = value.sorted {
          ($0.createdAtDate ?? .distantPast) >
          ($1.createdAtDate ?? .distantPast)
        }
        return TransactionSection(
          month: key,
          items: sortedItems,
          isExpanded: expandedSections[key] ?? false
        )
      }
      .sorted { lhs, rhs in
        let lDate = LiquidityDateFormatter.monthYearAbbrev.parseToDate(from: lhs.month) ?? .distantPast
        let rDate = LiquidityDateFormatter.monthYearAbbrev.parseToDate(from: rhs.month) ?? .distantPast
        return lDate > rDate
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

// MARK: Handle APIs
private extension TransactionsViewModel {
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
