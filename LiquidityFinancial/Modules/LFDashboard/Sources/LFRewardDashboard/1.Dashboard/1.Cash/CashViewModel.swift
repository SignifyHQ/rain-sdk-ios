import Foundation
import LFCard
import Factory
import NetSpendData
import NetSpendDomain
import AccountDomain
import AccountData
import LFUtilities
import LFBank
import LFTransaction

@MainActor
final class CashViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var isDisableView: Bool = false
  @Published var cashBalanceValue: Double = 0
  @Published var toastMessage: String?
  @Published var activity = Activity.loading
  @Published var cashCardDetails = CardModel.virtualDefault // MOCK DATA
  @Published var selectedAsset: AssetType = .usd
  @Published var navigation: Navigation?
  @Published var transactions: [TransactionModel] = []
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var accountID: String = .empty
  @Published var fullScreen: FullScreen?
    
  var transactionLimitEntity: Int {
    50
  }
  
  var transactionLimitOffset: Int {
    0
  }
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  private let guestHandler: () -> Void
  
  init(guestHandler: @escaping () -> Void) {
    self.guestHandler = guestHandler
    appearOperations()
    getACHInfo()
  }
  
  func appearOperations() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      await self.refresh()
    }
  }
  
  func refresh() async {
    do {
      activity = .loading
      isLoading = true
      if let account = try await refreshAccounts() {
        isLoading = false
        
        try getListConnectedAccount()
        
        try await loadTransactions(accountId: account.id)
        activity = transactions.isEmpty ? .addFunds : .transactions
      }
    } catch {
      activity = .addFunds
      log.error(error)
    }
  }
}

// MARK: - View Helpers
extension CashViewModel {
  func onClickedChangeAssetButton() {
    navigation = .changeAsset
  }
  
  func addMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.receive)
    } else {
      navigation = .addMoney
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.send)
    } else {
      navigation = .sendMoney
    }
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func guestCardTapped() {
    guestHandler()
  }
}

// MARK: - Private Functions
 extension CashViewModel {
  private func loadTransactions(accountId: String) async throws {
    defer { activity = .transactions }
    activity = .loading
    let transactions = try await accountRepository.getTransactions(
      accountId: accountId,
      currencyType: currencyType,
      transactionTypes: Constants.TransactionTypesRequest.fiat.types,
      limit: transactionLimitEntity,
      offset: transactionLimitOffset
    )
    self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
  }
  
  private func refreshAccounts() async throws -> LFAccount? {
    defer { isLoading = false }
    isLoading = true
    let accounts = try await accountRepository.getAccount(currencyType: currencyType)
    if let account = accounts.first {
      self.accountID = account.id
      self.accountDataManager.fiatAccountID = account.id
      self.accountDataManager.externalAccountID = account.externalAccountId
      self.cashBalanceValue = account.availableBalance
      self.selectedAsset = AssetType(rawValue: account.currency) ?? .usd
      return account
    }
    return nil
  }
  
  private func getListConnectedAccount() throws {
    Task {
      let sessionID = self.accountDataManager.sessionID
      let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
      let linkedAccount = response.linkedSources.compactMap({
        APILinkedSourceData(
          name: $0.name,
          last4: $0.last4,
          sourceType: APILinkSourceType(rawValue: $0.sourceType.rawString),
          sourceId: $0.sourceId,
          requiredFlow: $0.requiredFlow
        )
      })
      self.linkedAccount = linkedAccount
    }
  }
  
  private func getACHInfo() {
    Task {
      do {
        let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
        achInformation = ACHModel(
          accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
          routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
          accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
        )
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - Types
extension CashViewModel {
  enum Activity {
    case loading
    case addFunds
    case transactions
  }
  
  enum Navigation {
    case bankStatements
    case changeAsset
    case transactions
    case transactionDetail(TransactionModel)
    case addMoney
    case sendMoney
  }
  
  enum FullScreen: Identifiable {
    case fundCard(MoveMoneyAccountViewModel.Kind)

    var id: String {
      switch self {
      case .fundCard: return "fundCard"
      }
    }
  }
}
