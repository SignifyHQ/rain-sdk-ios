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
  @Published var selectedAsset: AssetType = .usdc
  @Published var navigation: Navigation?
  @Published var transactions: [TransactionModel] = []
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  
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
    getACHInfo()
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
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    if false { // userManager.isGuest TODO: Will be implemented later
      guestHandler()
    } else {
      Haptic.impact(.light).generate()
      navigation = .transactionDetail(transaction.id)
    }
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
    let transactions = try await accountRepository.getTransactions(accountId: accountId, currencyType: currencyType, limit: transactionLimitEntity, offset: transactionLimitOffset)
    self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
  }
  
  private func refreshAccounts() async throws -> LFAccount? {
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
    case transactionDetail(String?)
    case addMoney
    case sendMoney
  }
}
