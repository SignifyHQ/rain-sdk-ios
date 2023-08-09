import Combine
import Factory
import LFUtilities
import LFAccountOnboarding
import SwiftUI
import NetSpendData

// swiftlint:disable let_var_whitespace
protocol AppCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<AppCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: AppCoordinator.Route)
}

class AppCoordinator: AppCoordinatorProtocol {
  
  enum Route: Int {
    case onboarding
    case dashboard
  }
  
  @Injected(\.onboardingFlowCoordinator)
  private var onboardingFlowCoordinator
  
  private var subscribers: Set<AnyCancellable> = []
  let routeSubject: CurrentValueSubject<Route, Never> = .init(.onboarding)
  
  init() {
    onboardingFlowCoordinator
      .routeSubject
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setOnboardingRoute(route)
      }
      .store(in: &subscribers)
  }
  
  private func setOnboardingRoute(_ route: OnboardingFlowCoordinator.Route) {
    if route == .dashboard {
      set(route: .dashboard)
    } else {
      set(route: .onboarding)
    }
  }
  
  func set(route: Route) {
    guard routeSubject.value != route else { return }
    log.info("AppCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  func routeUser() {
    onboardingFlowCoordinator.routeUser()
  }
  
}
