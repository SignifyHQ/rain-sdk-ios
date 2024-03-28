import Foundation
import SwiftUI
import Factory
import NetSpendData
import NetspendDomain
import LFUtilities
import Combine
import NetspendSdk
import FraudForce
import OnboardingData
import Services

class WelcomeViewModel: ObservableObject {
  @LazyInjected(\.nsPersonRepository) var nsPersonRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var isPushToAgreementView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  lazy var getAggreementUseCase: NSGetAgreementUseCaseProtocol = {
    NSGetAgreementUseCase(repository: nsPersonRepository)
  }()
  
  private var cancellables: Set<AnyCancellable> = []
}

// MARK: - APIs Handler
extension WelcomeViewModel {
  func perfromInitialAccount() async {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      
      do {
        let agreement = try await getAggreementUseCase.execute()
        netspendDataManager.update(agreement: agreement)
        isPushToAgreementView = true
      } catch {
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handler
extension WelcomeViewModel {
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewsWelcome))
  }
}
