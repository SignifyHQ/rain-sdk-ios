import Foundation
import Combine
import Factory
import AuthorizationManager
import LFUtilities

// swiftlint:disable let_var_whitespace
protocol AppCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<AppCoordinator.Route, Never> { get }
  var authorizationManager: AuthorizationManagerProtocol { get }
  func routeUser()
  func set(route: AppCoordinator.Route)
}

class AppCoordinator: AppCoordinatorProtocol {
  
  enum Route {
    case initial
    case onboarding
    case welcome
  }
  
  let routeSubject: CurrentValueSubject<Route, Never>
  let authorizationManager: AuthorizationManagerProtocol
  
  init() {
    self.routeSubject = .init(.initial)
    self.authorizationManager = Container.shared.authorizationManager.callAsFunction()
  }
  
  func set(route: Route) {
    log.info("Setting route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  func routeUser() {
    if authorizationManager.isTokenValid() {
      routeSubject.value = .welcome
    } else {
      routeSubject.value = .onboarding
    }
  }
  
}
