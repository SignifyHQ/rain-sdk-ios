import LFUtilities
import Foundation
import AccountData
import RainFeature
import RainData
import RainDomain
import Factory
import Services

@MainActor
final class DashboardCardViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var isShowCardDetail = false
  @Published var isCreatingCard = false
  
  @Published var isNoCardTooltipShown = false
  @Published var toastMessage: String?
  
  lazy var createCardUseCase: RainCreateVirtualCardUseCaseProtocol = {
    RainCreateVirtualCardUseCase(repository: rainCardRepository)
  }()
}

// MARK: API Handling
extension DashboardCardViewModel {
  func createCard(onSuccess: @escaping () -> Void) {
    Task {
      defer { isCreatingCard = false }
      isCreatingCard = true
      
      do {
        _ = try await createCardUseCase.execute()
        NotificationCenter.default.post(name: .refreshListCards, object: nil)
        onSuccess()
        analyticsService.track(event: AnalyticsEvent(name: .createCardSuccess))
      } catch {
        toastMessage = error.userFriendlyMessage
        analyticsService.track(event: AnalyticsEvent(name: .createCardError))
      }
    }
  }
}
