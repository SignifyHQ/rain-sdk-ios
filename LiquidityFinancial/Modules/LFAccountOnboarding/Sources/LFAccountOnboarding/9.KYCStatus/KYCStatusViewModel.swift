import Foundation
import Factory
import NetSpendData
import LFUtilities
import OnboardingData
import OnboardingDomain
import UIKit
import LFServices

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
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.userDataManager) var userDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.intercomService) var intercomService
  
  var username: String {
    userDataManager.userNameDisplay
  }
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?
  
  init(state: KYCState) {
    _state = .init(initialValue: state)
  }
  
}

extension KYCStatusViewModel {
  
  func openIntercom() {
    intercomService.openIntercom()
  }
  
  //MAGIC PASS KYC DASHBOARD
#if DEBUG
  // swiftlint:disable force_unwrapping
  func magicPassKYC() {
    Task {
      do {
        let user = try await onboardingRepository.getUser(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
        var request = URLRequest(url: URL(string: "https://api-crypto.dev.liquidity.cc/v1/admin/users/\(user.userID)/approve")!)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { _, response, error in
          let httpResponse = response as? HTTPURLResponse
          log.debug("approved dashboard state: \(httpResponse?.statusCode ?? 000)")
          if let error = error {
            log.error(error.localizedDescription)
          }
        }
        .resume()
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
#endif
  
  func magicTapToLogout() {
    magicPassKYC()
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
              onboardingFlowCoordinator.set(route: .zeroHash)
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
