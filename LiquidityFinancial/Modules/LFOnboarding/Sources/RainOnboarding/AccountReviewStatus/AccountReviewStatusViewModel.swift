import Foundation
import Factory
import LFUtilities
import OnboardingData
import AccountData
import AccountDomain
import RainDomain
import OnboardingDomain
import UIKit
import Services
import LFStyleGuide
import AuthorizationManager
import NetworkUtilities
import CoreNetwork
import LFLocalizable

@MainActor
final class AccountReviewStatusViewModel: ObservableObject {
  @LazyInjected(\.rainOnboardingFlowCoordinator) var rainOnboardingFlowCoordinator
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rainRepository) var rainRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  @Published var state: AccountReviewStatus = .idle

  @Published var presentation: Presentation?
  @Published var popup: Popup?
  
  lazy var getUserUseCase: GetUserUseCaseProtocol = {
    GetUserUseCase(repository: accountRepository)
  }()
  
  lazy var getExternalVerificationLinkUseCase: GetExternalVerificationLinkUseCaseProtocol = {
    GetExternalVerificationLinkUseCase(repository: rainRepository)
  }()
  
  var username: String {
    accountDataManager.userNameDisplay
  }
  
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?
  
  init(state: AccountReviewStatus) {
    _state = .init(initialValue: state)
  }
}

// MARK: - API Handle
extension AccountReviewStatusViewModel {
  private func fetchAccountReviewStatus() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let user = try await getUserUseCase.execute()
        
        guard let accountReviewStatus = user.accountReviewStatusEnum else {
          handleUnclearAccountReviewStatus(user: user)
          return
        }
        
        switch accountReviewStatus {
        case .approved:
          handleApprovedAccountReview()
        case .rejected:
          state = AccountReviewStatus.reject
        case .inreview, .reviewing:
          guard state != AccountReviewStatus.inReview(username) else {
            return
          }
          state = AccountReviewStatus.inReview(username)
        }
      } catch {
        log.error(error.userFriendlyMessage)
        rainOnboardingFlowCoordinator.forceLogout()
      }
    }
  }
  
  private func getExternalVerificationLink() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let response = try await getExternalVerificationLinkUseCase.execute()
        
        guard let userID = response.paramsEntity?.userId else {
          return
        }
        let urlString = "\(response.url)?userId=\(userID)"
        
        guard let url = URL(string: urlString) else {
          return
        }
        
        presentation = .idv(url)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
}

// MARK: - View Handle
extension AccountReviewStatusViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onMagicPopupPrimaryButtonTapped() {
    closePopup()
    magicDashboardApproved()
  }
  
  func primaryAction() {
    switch state {
    case .inReview, .unclear:
      fetchAccountReviewStatus()
    case .reject:
      forcedLogout()
    case .missingInformation:
      // TODO: - Will be implemented in ENG-4232
      break
    case .identityVerification:
      getExternalVerificationLink()
    default:
      break
    }
  }
  
  func idvComplete() {
    Task {
      do {
        try await rainOnboardingFlowCoordinator.fetchOnboardingMissingSteps()
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func secondaryAction() {
    openSupportScreen()
  }
  
  func openMagicPopup() {
    popup = .magic
  }
  
  func closePopup() {
    popup = nil
  }
}

// MARK: - Private Functions
private extension AccountReviewStatusViewModel {
  // TODO: - We should think about moving functions like this into a service helper
  // swiftlint:disable force_unwrapping
  /// Magic function for automatically approving account review via the dashboard.
  func magicDashboardApproved() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      
      do {
        let user = try await getUserUseCase.execute()
        
        let urlString = APIConstants.devHost + "/v1/admin/users/\(user.userID)/approve"
        guard let url = URL(string: urlString) else {
          return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.POST.rawValue
        
        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        log.debug(
          Constants.DebugLog.dashboardApproved(statusCode: httpResponse?.statusCode ?? 000)
        )
        toastMessage = L10N.Common.Toast.DashboardApproved.message
      } catch {
        self.toastMessage = error.userFriendlyMessage
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func forcedLogout() {
    NotificationCenter.default.post(name: authorizationManager.logOutForcedName, object: nil)
  }
  
  func handleUnclearAccountReviewStatus(user: LFUser) {
    guard let reviewStatus = user.accountReviewStatus else {
      return
    }
    
    // There is data returned but does not match specific values
    let description = Constants.DebugLog.missingAccountStatus(
      status: String(describing: reviewStatus)
    ).value
    rainOnboardingFlowCoordinator.set(route: .unclear(description))
  }
  
  func handleApprovedAccountReview() {
    analyticsService.track(event: AnalyticsEvent(name: .kycStatusViewPass))
    rainOnboardingFlowCoordinator.set(route: .dashboard)
  }
}

  // MARK: - Types
extension AccountReviewStatusViewModel {
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
