import AccountDomain
import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities

@MainActor
public final class ReviewStatusViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @Published var reviewStatus: ReviewStatus
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  init(
    reviewStatus: ReviewStatus
  ) {
    self.reviewStatus = reviewStatus
  }
}

// MARK: - Binding Observables
extension ReviewStatusViewModel {}

// MARK: - Handling UI/UX Logic
extension ReviewStatusViewModel {}

// MARK: - Handling Interations
extension ReviewStatusViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        navigation = try await onboardingCoordinator.getOnboardingNavigation()
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
  
  func onCheckStatusButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        let accountReviewStatus = try await checkReviewStatus()
        guard let accountReviewStatusMapped = accountReviewStatus.enum
        else {
          reviewStatus = .unclear(status: accountReviewStatus.rawValue ?? "Unknown")
          
          return
        }
        
        switch accountReviewStatusMapped {
        case .approved:
          reviewStatus = .approved
        case .rejected:
          reviewStatus = .rejected
        case .inreview, .reviewing:
          reviewStatus = .inReview
        }
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
  
  func onLogoutButtonTap() {
    onboardingCoordinator.forceLogout()
  }
}

// MARK: - API Calls
extension ReviewStatusViewModel {
  private func checkReviewStatus(
  ) async throws -> (enum: AccountDomain.AccountReviewStatus?, rawValue: String?) {
    return try await onboardingCoordinator.getUserReviewStatus()
  }
}

// MARK: - Helper Functions
extension ReviewStatusViewModel {}

// MARK: - Private Enums
extension ReviewStatusViewModel {
  enum ReviewStatus: Equatable {
    case inReview
    case approved
    case rejected
    case unclear(status: String)
    
    static func == (lhs: ReviewStatus, rhs: ReviewStatus) -> Bool {
      switch (lhs, rhs) {
      case (.inReview, .inReview),
        (.approved, .approved),
        (.rejected, .rejected),
        (.unclear, .unclear):
        
        return true
      default:
        return false
      }
    }
    
    var title: String {
      switch self {
      case .inReview:
        "Your application is in review. "
      case .approved:
        "Congratulations!"
      case .rejected:
        "We regret to inform you that your\napplication has not been approved."
      case .unclear:
        "The status of your application is unknown."
      }
    }
    
    var subtitle: String {
      switch self {
      case .inReview:
        "You will be notified via email/phone number with\nthe status of the application."
      case .approved:
        "Your application has been approved, get started\nwith the Avalanche app today."
      case .rejected:
        "Our team reviewed your documents and had to\ndeny your application."
      case .unclear(let status):
        status
      }
    }
  }
}
