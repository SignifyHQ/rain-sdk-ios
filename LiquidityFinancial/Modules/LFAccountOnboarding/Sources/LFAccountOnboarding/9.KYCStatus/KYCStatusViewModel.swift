import Foundation
import Factory
import NetSpendData
import LFUtilities
import OnboardingData
import OnboardingDomain

@MainActor
final class KYCStatusViewModel: ObservableObject {
  enum Navigation {
    case passport
    case address
  }
  
  @Published var state: KYCState = .idle
  @Published var presentation: Presentation?
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  @Injected(\.netspendRepository) var netspendRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  @Injected(\.userDataManager) var userDataManager
  @Injected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  var username: String {
    userDataManager.userNameDisplay
  }
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?
  
  init(state: KYCState) {
    _state = .init(initialValue: state)
  }
}

  // MARK: - View Helpers
extension KYCStatusViewModel {  
  func magicTapToLogout() {
      // userManager.logout()
  }
  
  func primaryAction() {
    switch state {
    case .inReview:
      fetchNewStatus()
    default:
      break
    }
  }
  
  func idvComplete() {
    presentation = nil
    addRefreshTimer()
  }
  
  func secondaryAction() {
    switch state {
    case .inReview:
      break
    default:
      break
    }
  }
  
  func fetchNewStatus() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID)
        if onboardingState.missingSteps.isEmpty {
          onboardingFlowCoordinator.set(route: .dashboard)
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            let workflowsMissingStep = WorkflowsMissingStep.allCases.map { $0.rawValue }
            if (onboardingState.missingSteps.first(where: { workflowsMissingStep.contains($0) }) != nil) {
              return
            } else {
              //TODO: Tony need review
              onboardingFlowCoordinator.set(route: .dashboard)
            }
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              onboardingFlowCoordinator.set(route: .welcome)
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
                //TODO: Tony review it
            } else if states.contains(OnboardingMissingStep.cardProvision) {
                //TODO: Tony review it
            }
          }
        }
      } catch {
        onboardingFlowCoordinator.set(route: .welcome)
        log.error(error.localizedDescription)
      }
    }
  }
  
  func checkOnboardingState(onCompletion: @escaping () -> Void) {
    
  }
}

  // MARK: - Private Functions
private extension KYCStatusViewModel {
  func addRefreshTimer() {
      // guard !isPolling else { return }
      //    fetchCount = 0
      //    state = .loading
      //    updateUser()
      //    autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
      //      guard let self = self else { return }
      //      DispatchQueue.main.async {
      //        self.updateUser()
      //      }
      //    }
  }
  
  func clearRefreshTimer() {
    autoRefreshTimer?.invalidate()
  }
  
  func incrementTimer() {
    fetchCount += 1
    if fetchCount > 5 {
      clearRefreshTimer()
    }
  }
}

  // MARK: - Types
extension KYCStatusViewModel {
  enum Presentation: Identifiable {
    case idv(URL)
    
    var id: String {
      switch self {
      case .idv: return "idv"
      }
    }
  }
}
