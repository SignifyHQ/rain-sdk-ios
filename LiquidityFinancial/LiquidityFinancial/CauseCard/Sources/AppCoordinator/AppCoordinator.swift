import Combine
import Factory
import LFUtilities
import SolidOnboarding
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
  
  enum Route: Hashable, Identifiable {
    case onboarding
    case onboardingPhone
    case dashboard
    case dumpOut(SolidOnboardingFlowCoordinator.Route)
    
    public static func == (lhs: AppCoordinator.Route, rhs: AppCoordinator.Route) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    public var id: String {
      String(describing: self)
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
  
  @LazyInjected(\.authorizationManager)
  private var authorizationManager
  @LazyInjected(\.solidOnboardingFlowCoordinator)
  private var solidOnboardingFlowCoordinator
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
    solidOnboardingFlowCoordinator
      .routeSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
        self?.setOnboardingRoute(route)
      }
      .store(in: &subscribers)
    
    NotificationCenter.default
      .publisher(for: authorizationManager.logOutForcedName)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        log.warning("The server has forcibly logged out the user")
        self?.logout()
        self?.set(route: .onboardingPhone)
      }
      .store(in: &subscribers)
  }
    
  func set(route: Route) {
    log.info("AppCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  func routeUser() {
    solidOnboardingFlowCoordinator.routeUser()
  }
  
  func logout() {
    authorizationManager.clearToken()
    accountDataManager.clearUserSession()
    customerSupportService.pushEventLogout()
    pushNotificationService.signOut()
  }
  
  private func setOnboardingRoute(_ route: SolidOnboardingFlowCoordinator.Route) {
    if route == .dashboard {
      setUpPushNotification()
      fetchFeatureFlags()
      set(route: .dashboard)
    } else {
      set(route: .onboarding)
    }
  }
  
  private func setUpPushNotification() {
    pushNotificationService.setUp()
  }
  
  private func fetchFeatureFlags() {
    featureFlagManager.fetchEnabledFeatureFlags()
  }
}
