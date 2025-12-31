import Factory
import Foundation
import LFStyleGuide

@MainActor
public final class LandingViewModel: ObservableObject {
  @LazyInjected(\.environmentService) var environmentService
  
  @Published var navigation: Navigation?
  
  @Published var currentToast: ToastData? = nil
}

// MARK: - Handling Interations
extension LandingViewModel {
  func onLoginButtonTap(
    with authMethod: AuthMethod
  ) {
    navigation = .authentication(authMethod: authMethod)
  }
  
  func onSignupButtonTap(
  ) {
    navigation = .walkthrough
  }
  
  func onSwitchEnvironmentButtonTap(
  ) {
    environmentService.toggleEnvironment()
    currentToast = ToastData(
      type: .warning,
      title: "You have switched to \(environmentService.networkEnvironment == .productionLive ? "Live" : "Test") mode. Please restart the app for the changes to take effect."
    )
  }
}

// MARK: - Private Enums
extension LandingViewModel {
  enum Navigation {
    case walkthrough
    case authentication(authMethod: AuthMethod)
  }
  
  enum AuthMethod {
    case phone
    case email
  }
}
