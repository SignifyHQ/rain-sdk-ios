import Foundation
import LFCard
import Factory
import CardData
import CardDomain
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

  @LazyInjected(\.accountRepository) var accountRepository
  
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
    }
  }
  
  func loadTransactions() async {
    activity = .transactions
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
        let accounts = try await accountRepository.getAccount(currencyType: "FIAT")
        if let account = accounts.first { // TODO: Just get one
          self.cashBalanceValue = account.availableBalance
          self.selectedAsset = AssetType(rawValue: account.currency) ?? .usd
        }
        log.info(accounts)
      } catch {
        log.error(error.localizedDescription)
      }
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
  }
}
