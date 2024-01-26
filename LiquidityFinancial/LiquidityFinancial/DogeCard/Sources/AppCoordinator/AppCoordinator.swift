import Combine
import Factory
import LFUtilities
import NetspendOnboarding
import SwiftUI
import AuthorizationManager
import LFFeatureFlags

  // swiftlint:disable let_var_whitespace
protocol AppCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<AppCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: AppCoordinator.Route)
}

class AppCoordinator: AppCoordinatorProtocol {
  
  enum Route {
    case onboarding
    case onboardingPhone
    case dashboard
    case dumpOut(NSOnboardingFlowCoordinator.Route)
  }
  
  @LazyInjected(\.authorizationManager)
  private var authorizationManager
  @Injected(\.nsOnboardingFlowCoordinator)
  private var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService)
  private var customerSupportService
  @LazyInjected(\.accountRepository)
  private var accountRepository
  @LazyInjected(\.accountDataManager)
  private var accountDataManager
  @LazyInjected(\.pushNotificationService)
  private var pushNotificationService
  @LazyInjected(\.featureFlagManager)
  private var featureFlagManager
  
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
  
  private func setOnboardingRoute(_ route: NSOnboardingFlowCoordinator.Route) {
    if route == .dashboard {
      fetchFeatureFlags()
      set(route: .dashboard)
    } else {
      set(route: .onboarding)
    }
  }
  
  private func fetchFeatureFlags() {
    featureFlagManager.fetchEnabledFeatureFlags()
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
    customerSupportService.pushEventLogout()
    pushNotificationService.signOut()
  }
}
