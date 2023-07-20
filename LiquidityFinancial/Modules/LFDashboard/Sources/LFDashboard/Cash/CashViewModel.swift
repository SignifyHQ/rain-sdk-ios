import Foundation

@MainActor
final class CashViewModel: ObservableObject {
  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = true
  @Published var cashBalanceValue: Double = 0
  @Published var activity = Activity.loading
  @Published var cashCardDetails = CardModel.default // MOCK DATA
  @Published var selectedAsset: AssetType = .usdc
  @Published var transactions: [String] = [] // FAKE TYPE -> TransactionModel
  @Published var navigation: Navigation?

  private let guestHandler: () -> Void
  
  init(guestHandler: @escaping () -> Void) {
    self.guestHandler = guestHandler
    // MOCK DATA
    cashBalanceValue = 0
    isLoading = false
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
