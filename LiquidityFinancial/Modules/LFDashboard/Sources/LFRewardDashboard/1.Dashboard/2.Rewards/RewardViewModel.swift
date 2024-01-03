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
  
  private var isFirstLoad: Bool = false
  private var isLoading: Bool = false
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  init() {
    isFirstLoad = true
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
  private func fetchFiatAccountID() async throws -> String {
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
      do {
        defer { isLoading = false }
        isLoading = true
        
        let accountID = try await fetchFiatAccountID()
        fiatAccountID = accountID
        
        if isFirstLoad {
          feed = .loading

          guard accountID.isEmpty == false else {
            // reset state for first load
            isFirstLoad = false
            
            feed = .success([])
            return
          }
          
          let models = try await apiFetchTransactions(accountId: accountID)
          feed = .success(models)
          
          // reset state for first load
          isFirstLoad = false
        } else {

        }
      } catch {
        if isFirstLoad {
          feed = .failure(error)
          // reset state for first load
          isFirstLoad = false
        }
        log.error(error.userFriendlyMessage)
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
