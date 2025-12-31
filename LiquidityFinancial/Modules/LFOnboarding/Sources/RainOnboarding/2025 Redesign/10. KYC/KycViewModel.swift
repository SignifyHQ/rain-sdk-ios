import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import RainDomain

@MainActor
public final class KycViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.rainRepository) var rainRepository
  
  @Published var navigation: OnboardingNavigation?
  @Published var webViewNavigation: WebViewNavigation?
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  lazy var getExternalVerificationLinkUseCase: GetExternalVerificationLinkUseCaseProtocol = {
    GetExternalVerificationLinkUseCase(repository: rainRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    return true
  }
  
  init() {}
}

// MARK: - Binding Observables
extension KycViewModel {}

// MARK: - Handling UI/UX Logic
extension KycViewModel {}

// MARK: - Handling Interations
extension KycViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    Task {
      isLoading = true
      
      do {
        // Attempt to get and build the verification link
        let verificationUrl = try await getVerificationUrl()
        // Navigate to the web view with the fetched link
        webViewNavigation = .kyc(url: verificationUrl)
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
  
  func onWebViewCompleted() {
    Task {
      defer {
        isLoading = false
      }
      
      do {
        // Get the next navigation steps when the webview completes successfully
        // or user closes it
        let nextNavigation = try await onboardingCoordinator.getOnboardingNavigation()
        // Do nothing if navigation should take you to the same (current) screen
        if case .verificationRequired = nextNavigation {
          return
        }
        // Otherwise, perform the navigation
        navigation = nextNavigation
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - API Calls
extension KycViewModel {
  private func getVerificationUrl() async throws -> URL {
    // Get the verification link from the backend
    let response = try await getExternalVerificationLinkUseCase.execute()
    // Fetch the userID and build the verification url
    // throw error if it fails
    guard let userID = response.paramsEntity?.userId,
          let url = URL(string: "\(response.url)?userId=\(userID)")
    else {
      throw LFErrorObject(message: "Error fetching the verification link")
    }
    // Return the verification url
    return url
  }
}

// MARK: - Helper Functions
extension KycViewModel {}

// MARK: - Private Enums
extension KycViewModel {
  enum WebViewNavigation: Identifiable {
    case kyc(url: URL)
    
    var id: String {
      "kyc"
    }
  }
}
