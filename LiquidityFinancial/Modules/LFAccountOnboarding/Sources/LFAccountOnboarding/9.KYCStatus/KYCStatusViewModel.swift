import Foundation
import Factory
import NetSpendData
import LFUtilities
import OnboardingData

@MainActor
public final class KYCStatusViewModel: ObservableObject {
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
  
  var username: String {
    userDataManager.userNameDisplay
  }
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?
  
  public init(state: KYCState) {
    _state = .init(initialValue: state)
  }
}

  // MARK: - View Helpers
extension KYCStatusViewModel {
  func openIntercom() {
      // intercomService.openIntercom()
  }
  
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
        guard let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID) as? APIOnboardingState else { return }
        if onboardingState.mapToEnum().isEmpty {
            //Go Home Screen
        } else {
          for state in onboardingState.mapToEnum() where state == .primaryPersonKYCApprove {
            // Do nothing
          }
        }
      } catch {
        log.error(error.localizedDescription)
        toastMessage = error.localizedDescription
      }
    }
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
