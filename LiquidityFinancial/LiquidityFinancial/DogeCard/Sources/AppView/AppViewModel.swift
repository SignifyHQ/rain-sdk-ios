import Foundation
import UIKit
import Combine
import LFUtilities
import Factory
import NetspendOnboarding
import AccountService
import NetSpendData

class AppViewModel: ObservableObject {
  
  @Injected(\.coordinator) var coordinator
  
  @Published var route = AppCoordinator.Route.onboarding
  
  private var subscribers: Set<AnyCancellable> = []
  
  init() {
    coordinator
      .routeSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setRoute(route)
      }
      .store(in: &subscribers)
    
    coordinator.routeUser()
    
    Task { @MainActor in
      registerInjection()
    }
  }
  
  @MainActor func registerInjection() {
    Container.shared.fiatAccountService.register {
      NetspendAccountService()
    }
  }
  
  func setDumpOutRoute(_ route: NSOnboardingFlowCoordinator.Route) {
    setRoute(.dumpOut(route))
  }
  
  private func setRoute(_ route: AppCoordinator.Route) {
      // Setting a new route will change the root view of the `NavigationView` that we have on `AppView`.
      // If there is a navigation stack built for the current route, we don't want to pop them to the root and then change this view.
      // Instead, what we want is to replace the root view without an animation.
      //
      // To do so, we need to disable animation on the `UINavigationBar`, set the new route and then enable the animations again
      // (with a small delay for the flag to be changed after the `NavigationView` actually chages its base view).
    UINavigationBar.setAnimationsEnabled(false)
    self.route = route
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      UINavigationBar.setAnimationsEnabled(true)
    }
  }
}
