import Foundation
import LFCard
import Factory
import NetSpendData
import NetSpendDomain
import LFUtilities

@MainActor
final class CashViewModel: ObservableObject {
  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var cashBalanceValue: Double = 0
  @Published var activity = Activity.loading
  @Published var cashCardDetails = CardModel.virtualDefault // MOCK DATA
  @Published var selectedAsset: AssetType = .usdc
  @Published var transactions: [String] = [] // FAKE TYPE -> TransactionModel
  @Published var navigation: Navigation?
  @Published var linkedAccount: [APILinkedSourceData] = []

  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  var currencyType: String {
    "FIAT"
  }
  
  private let guestHandler: () -> Void
  
  init(guestHandler: @escaping () -> Void) {
    self.guestHandler = guestHandler
    getAccountInfomation()
  }
}

extension CashViewModel {
  func appearOperations() {
    Task {
      await refresh()
    }
  }
  
  func refresh() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
          // await self.accountManager.refreshAccounts(loadCards: false)
      }
      group.addTask {
        await self.loadTransactions()
      }
      group.addTask {
        await self.getListConnectedAccount()
      }
    }
  }
  
  func loadTransactions() async {
    activity = .transactions
  }
  
  func getListConnectedAccount() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedAccount = response.linkedSources.compactMap({
          APILinkedSourceData(
            name: $0.name,
            last4: $0.last4,
            sourceType: APILinkSourceType(rawValue: $0.sourceType.rawString),
            sourceId: $0.sourceId
          )
        })
        self.linkedAccount = linkedAccount
      } catch {
        log.error(error)
      }
    }
  }
  
  func onClickedSeeAllButton() {
  }
  
  func guestCardTapped() {
    guestHandler()
  }
  
  func onClickedChangeAssetButton() {
    navigation = .changeAsset
  }
  
  func getAccountInfomation() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      defer { isLoading = false }
      isLoading = true
      do {
        let accounts = try await accountRepository.getAccount(currencyType: currencyType)
        if let account = accounts.first { // TODO: Just get one
          self.cashBalanceValue = account.availableBalance
          self.selectedAsset = AssetType(rawValue: account.currency) ?? .usd
          await self.getTransactions(accountId: account.id)
        }
        log.info(accounts)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func getTransactions(accountId: String) async {
    do {
      let transactions = try await accountRepository.getTransactions(accountId: accountId, currencyType: currencyType, limit: 10, offset: 1)
      log.info(transactions)
    } catch {
      log.error(error.localizedDescription)
    }
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
  }
}
