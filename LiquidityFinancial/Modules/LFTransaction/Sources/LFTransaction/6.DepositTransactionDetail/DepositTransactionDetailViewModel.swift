import AccountDomain
import AccountData
import NetSpendData
import LFUtilities
import Factory
import Combine

@MainActor
final class DepositTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager

  @Published var navigation: Navigation?
  @Published var linkedAccount: [APILinkedSourceData] = []
  
  private var cancellable: Set<AnyCancellable> = []
  
  init() {
    subscribeLinkedAccounts()
  }
}

// MARK: Functions
extension DepositTransactionDetailViewModel {
  func connectDebitCard() {
    navigation = .addBank
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else {
        return
      }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
}

// MARK: Types
extension DepositTransactionDetailViewModel {
  enum Navigation {
    case addBank
  }
}
