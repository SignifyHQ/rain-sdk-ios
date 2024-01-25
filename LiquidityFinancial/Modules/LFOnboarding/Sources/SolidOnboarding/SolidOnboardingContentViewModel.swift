import Foundation
import Combine
import SwiftUI
import Factory
import OnboardingData
import LFUtilities
import AuthorizationManager
import OnboardingComponents

class SolidOnboardingContentViewModel: ObservableObject {
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  @Published var route = SolidOnboardingFlowCoordinator.Route.initial
  
  private var subscribers: Set<AnyCancellable> = []
  
  init() {
    solidOnboardingFlowCoordinator
      .routeSubject
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setRoute(route)
      }
      .store(in: &subscribers)
  }
  
  private func setRoute(_ route: SolidOnboardingFlowCoordinator.Route) {
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
