import Combine
import Factory
import LFUtilities
import LFAccountOnboarding
import SwiftUI
import NetSpendData
import AuthorizationManager

// swiftlint:disable let_var_whitespace
protocol AppCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<AppCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: AppCoordinator.Route)
}

class AppCoordinator: AppCoordinatorProtocol {
  
  enum Route: Int {
    case onboarding
    case onboardingPhone
    case dashboard
  }
  
  @LazyInjected(\.authorizationManager)
  private var authorizationManager
  @Injected(\.onboardingFlowCoordinator)
  private var onboardingFlowCoordinator
  @LazyInjected(\.intercomService)
  private var intercomService
  @LazyInjected(\.accountRepository)
  private var accountRepository
  @LazyInjected(\.accountDataManager)
  private var accountDataManager
  @LazyInjected(\.pushNotificationService)
  private var pushNotificationService
  
  private var subscribers: Set<AnyCancellable> = []
  let routeSubject: CurrentValueSubject<Route, Never> = .init(.onboarding)
  
  init() {
    onboardingFlowCoordinator
      .routeSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setOnboardingRoute(route)
      }
      .store(in: &subscribers)
    
    NotificationCenter.default
      .publisher(for: authorizationManager.logOutForcedName)
      .sink { [weak self] _ in
        log.warning("The server has forcibly logged out the user")
        self?.logout()
        self?.set(route: .onboardingPhone)
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
    log.info("AppCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  func routeUser() {
    onboardingFlowCoordinator.routeUser()
  }
  
  func logout() {
    authorizationManager.clearToken()
    accountDataManager.clearUserSession()
    intercomService.pushEventLogout()
    pushNotificationService.signOut()
  }
}
