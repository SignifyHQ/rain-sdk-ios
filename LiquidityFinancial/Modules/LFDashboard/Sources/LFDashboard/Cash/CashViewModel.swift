import Foundation
import LFCard
import Factory
import NetSpendData
import NetSpendDomain
import AccountDomain
import AccountData
import LFUtilities

@MainActor
final class CashViewModel: ObservableObject {
  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var cashBalanceValue: Double = 0
  @Published var activity = Activity.loading
  @Published var cashCardDetails = CardModel.virtualDefault // MOCK DATA
  @Published var selectedAsset: AssetType = .usdc
  @Published var navigation: Navigation?
  @Published var transactions: [TransactionModel] = []
  @Published var linkedAccount: [APILinkedSourceData] = []
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  var currencyType: String {
    "FIAT"
  }
  
  var transactionLimitEntity: Int {
    50
  }
  
  var transactionLimitOffset: Int {
    0
  }
  
  private let guestHandler: () -> Void
  
  init(guestHandler: @escaping () -> Void) {
    self.guestHandler = guestHandler
  }
}

extension CashViewModel {
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
        activity = .transactions
        
      }
    } catch {
      log.error(error)
    }
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func guestCardTapped() {
    guestHandler()
  }
  
  func onClickedChangeAssetButton() {
    navigation = .changeAsset
  }
  
  func addMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
        // fullScreen = .fundCard
        // TODO: Will implement later
    } else {
      navigation = .addMoney
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
        // fullScreen = .fundCard
        // TODO: Will implement later
    } else {
      navigation = .sendMoney
    }
  }
}

// MARK: - Types Private
private extension CashViewModel {
  func loadTransactions(accountId: String) async throws {
    defer { activity = .transactions }
    activity = .loading
    let transactions = try await accountRepository.getTransactions(accountId: accountId, currencyType: currencyType, limit: transactionLimitEntity, offset: transactionLimitOffset)
    self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
  }
  
  func refreshAccounts() async throws -> LFAccount? {
    defer { isLoading = false }
    isLoading = true
    let accounts = try await accountRepository.getAccount(currencyType: currencyType)
    if let account = accounts.first { // TODO: Temp Just get one
      self.accountDataManager.accountID = account.id
      self.cashBalanceValue = account.availableBalance
      self.selectedAsset = AssetType(rawValue: account.currency) ?? .usd
      return account
    }
    return nil
  }
  
  func getListConnectedAccount() throws {
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
}

// MARK: - Types
extension CashViewModel {
  enum Activity {
    case loading
    case transactions
  }
  
  enum Navigation {
    case bankStatements
    case changeAsset
    case transactions
    case addMoney
    case sendMoney
  }
}
