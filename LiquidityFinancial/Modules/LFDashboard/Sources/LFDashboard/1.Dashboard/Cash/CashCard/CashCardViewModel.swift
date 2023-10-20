import LFUtilities
import Foundation
import AccountData
import LFNetSpendCard
import NetSpendData
import NetspendDomain
import Factory
import LFServices

@MainActor
final class CashCardViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var isShowCardDetail = false
  @Published var isCreatingCard = false
  @Published var toastMessage: String?
  @Published var cardActivated: CardModel?
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
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
        analyticsService.track(event: AnalyticsEvent(name: .createCardSuccess))
      } catch {
        toastMessage = error.localizedDescription
        analyticsService.track(event: AnalyticsEvent(name: .createCardError))
      }
    }
  }
}
