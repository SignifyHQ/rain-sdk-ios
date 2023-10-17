import Foundation
import Combine
import SwiftUI
import Factory
import OnboardingData
import LFUtilities
import AuthorizationManager
import BaseOnboarding

class NSOnboardingContentViewModel: ObservableObject {
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  @Published var route = NSOnboardingFlowCoordinator.Route.initial
  
  private var subscribers: Set<AnyCancellable> = []
  
  init() {
    onboardingFlowCoordinator
      .routeSubject
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setRoute(route)
      }
      .store(in: &subscribers)
  }
  
  private func setRoute(_ route: NSOnboardingFlowCoordinator.Route) {
    if route == .dashboard { // ignore logic handle dashboard here
      return
    }
    UINavigationBar.setAnimationsEnabled(false)
    self.route = route
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      UINavigationBar.setAnimationsEnabled(true)
    }
  }
  
  func contactSupport() {
    customerSupportService.openSupportScreen()
  }
  
  func forcedLogout() {
    NotificationCenter.default.post(name: authorizationManager.logOutForcedName, object: nil)
  }
}
