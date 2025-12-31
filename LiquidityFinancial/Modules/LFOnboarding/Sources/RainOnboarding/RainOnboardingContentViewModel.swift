import Foundation
import Combine
import SwiftUI
import Factory
import OnboardingData
import LFUtilities
import AuthorizationManager
import BaseOnboarding

final class RainOnboardingContentViewModel: ObservableObject {
  @LazyInjected(\.rainOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  @Published var route = RainOnboardingFlowCoordinator.Route.initial
  
  private var cancellables: Set<AnyCancellable> = []
  
  init() {
    oberserveOnboardingFlowCoordinator()
  }
}

// MARK: - View Handler
extension RainOnboardingContentViewModel {
  func onAppear() {
    customerSupportService.loginUnidentifiedUser()
  }
  
  func contactSupport() {
    customerSupportService.openSupportScreen()
  }
  
  func forcedLogout() {
    NotificationCenter.default.post(name: authorizationManager.logOutForcedName, object: nil)
  }
}

// MARK: - Private Functions
private extension RainOnboardingContentViewModel {
  func oberserveOnboardingFlowCoordinator() {
    onboardingFlowCoordinator
      .routeSubject
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setRoute(route)
      }
      .store(in: &cancellables)
  }
  
  func setRoute(
    _ route: RainOnboardingFlowCoordinator.Route
  ) {
    if route == .dashboard { // ignore logic handle dashboard here
      return
    }
    
    UINavigationBar.setAnimationsEnabled(false)
    
    self.route = route
    
    DispatchQueue.main.asyncAfter(
      deadline: .now() + 0.2
    ) {
      UINavigationBar.setAnimationsEnabled(true)
    }
  }
}
