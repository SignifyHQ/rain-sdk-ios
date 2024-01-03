import Foundation
import Factory
import NetSpendData
import LFUtilities
import OnboardingData
import AccountData
import OnboardingDomain
import UIKit
import Services
import LFStyleGuide
import AuthorizationManager
import ZerohashData
import ZerohashDomain
import NetworkUtilities

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
  @Published var popup: Popup?
  
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.analyticsService) var analyticsService
  
  var username: String {
    accountDataManager.userNameDisplay
  }
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?
  
  init(state: KYCState) {
    _state = .init(initialValue: state)
  }
  
}

extension KYCStatusViewModel {
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  // MARK: MAGIC PASS KYC DASHBOARD
  
  // swiftlint:disable force_unwrapping
  func magicPassKYC() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let user = try await accountRepository.getUser()
        let urlString = APIConstants.devHost + "/v1/admin/users/\(user.userID)/approve"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        log.debug("approved dashboard state: \(httpResponse?.statusCode ?? 000)")
        self.toastMessage = "You have been approved by the Dashboard. Please click the button Check Status and go Next Step"
      } catch {
        self.toastMessage = error.userFriendlyMessage
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func primaryAction() {
    switch state {
    case .inReview:
      fetchNewStatus()
    case .reject:
      forcedLogout()
    case .missingInfo, .documentInReview:
      forcedLogout()
    default:
      break
    }
  }
  
  func idvComplete() {
    presentation = nil
    addRefreshTimer()
  }
  
  func secondaryAction() {
    openSupportScreen()
  }
  
  func fetchNewStatus() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let user = try await accountRepository.getUser()
        if let accountReviewStatus = user.accountReviewStatusEnum {
          switch accountReviewStatus {
          case .approved:
            try await fetchZeroHashStatus()
          case .rejected:
            state = KYCState.reject
          case .inreview, .reviewing:
            if state != KYCState.inReview(username) {
              state = KYCState.inReview(username)
            }
          }
        }
      } catch {
        
        log.error(error.userFriendlyMessage)
        
        onboardingFlowCoordinator.forcedLogout()
      }
    }
  }

  func fetchZeroHashStatus() async throws {
    let result = try await zerohashRepository.getOnboardingStep()
    if result.mapToEnum().contains(.createAccount) {
      onboardingFlowCoordinator.set(route: .zeroHash)
    } else {
      analyticsService.track(event: AnalyticsEvent(name: .kycStatusViewPass))
      onboardingFlowCoordinator.set(route: .dashboard)
    }
  }
  
  func openMagicPopup() {
    popup = .magic
  }
  
  func closePopup() {
    popup = nil
  }
  
  func forcedLogout() {
    NotificationCenter.default.post(name: authorizationManager.logOutForcedName, object: nil)
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
  
  enum Popup {
    case inReview
    case magic
  }
}
