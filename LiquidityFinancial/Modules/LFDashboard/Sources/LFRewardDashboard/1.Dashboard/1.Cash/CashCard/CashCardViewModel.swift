import LFUtilities
import Foundation
import AccountData
import LFSolidCard
import NetSpendData
import BankDomain
import Factory

@MainActor
final class CashCardViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published var isShowCardDetail = false
  @Published var isCreatingCard = false
  @Published var toastMessage: String?
  @Published var cardActivated: CardModel?
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  init() {
  }
}

// MARK: API Functions
extension CashCardViewModel {
  func createCard(onSuccess: @escaping () -> Void) {
    Task {
      defer { isCreatingCard = false }
      isCreatingCard = true
      do {
        _ = try await cardUseCase.createCard(sessionID: accountDataManager.sessionID)
        NotificationCenter.default.post(name: .refreshListCards, object: nil)
        onSuccess()
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
}
