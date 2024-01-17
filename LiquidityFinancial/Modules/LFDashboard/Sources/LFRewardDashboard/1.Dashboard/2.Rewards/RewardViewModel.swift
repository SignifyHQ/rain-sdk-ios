import Foundation
import LFUtilities
import LFLocalizable
import LFTransaction
import LFRewards
import AccountData
import AccountDomain
import Factory
import AccountService

@MainActor
class RewardViewModel: ObservableObject {
  @Injected(\.accountDataManager) var accountDataManager
  @Injected(\.accountRepository) var accountRepository
  @Injected(\.fiatAccountService) var fiatAccountService
  
  @Published var feed: DataStatus<TransactionModel> = .idle
  @Published var navigation: Navigation?
  @Published var toastMessage: String = ""
  @Published var fiatAccountID: String = ""
  @Published var isFirstLoading: Bool = true
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  init() {
    apiRefreshData()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Actions
extension RewardViewModel {
  func refresh() {
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
  func fetchFiatAccountID() async throws -> String {
    var account = self.accountDataManager.fiatAccounts.first
    if account == nil {
      let listAccount = try await fiatAccountService.getAccounts()
      self.accountDataManager.addOrUpdateAccounts(listAccount)
      account = listAccount.first
    }
    return account?.id ?? ""
  }
  
  func apiRefreshData() {
    Task {
      defer { isFirstLoading = false }
      
      do {
        let accountID = try await fetchFiatAccountID()
        fiatAccountID = accountID
        
        guard accountID.isEmpty == false else {
          feed = .success([])
          return
        }
        
        let models = try await apiFetchTransactions(accountId: accountID)
        feed = .success(models)
      } catch {
        log.error(error.userFriendlyMessage)
        feed = .failure(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func apiFetchTransactions(accountId: String) async throws -> [TransactionModel] {
    guard accountId.isEmpty == false else { return [] }
    let transactions = try await accountRepository.getTransactions(
      accountId: accountId,
      currencyType: currencyType,
      transactionTypes: Constants.TransactionTypesRequest.rewardCashBack.types,
      limit: 20,
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
