import Foundation
import Combine
import SwiftUI
import Factory

class OnboardingContentViewModel: ObservableObject {
  @Injected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var route = OnboardingFlowCoordinator.Route.initial
  
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
  
  private func setRoute(_ route: OnboardingFlowCoordinator.Route) {
    if route == .dashboard { // ignore logic handle dashboard here
      return
    }
    UINavigationBar.setAnimationsEnabled(false)
    self.route = route
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      UINavigationBar.setAnimationsEnabled(true)
    }
  }
}
