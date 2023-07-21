import Foundation
import Combine
import Factory
import AuthorizationManager
import LFUtilities
import LFAccountOnboarding
import OnboardingDomain
import OnboardingData
import NetSpendData
import SwiftUI

// swiftlint:disable let_var_whitespace
protocol AppCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<AppCoordinator.Route, Never> { get }
  var authorizationManager: AuthorizationManagerProtocol { get }
  func routeUser()
  func set(route: AppCoordinator.Route)
}

class AppCoordinator: AppCoordinatorProtocol {
  
  @Injected(\.netspendRepository) var netspendRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  @Injected(\.userDataManager) var userDataManager
  @Injected(\.onboardingRepository) var onboardingRepository
  
  enum Route {
    case initial
    case onboarding
    case welcome
    case onKYCReview
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
      getCurrentState()
    } else {
      routeSubject.value = .onboarding
    }
  }
  
}

extension AppCoordinator {
  func getCurrentState() {
    Task { @MainActor in
      do {
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID)
        if onboardingState.missingSteps.isEmpty {
          routeSubject.value = .welcome
        } else {
          let state = onboardingState.missingSteps.contains(where: { item in
            item == "primary_person_kyc_approve" || item == "provide_documents"
          })
          if state {
            routeSubject.value = .onKYCReview
          } else {
            routeSubject.value = .welcome
          }
        }
      } catch {
        routeSubject.value = .onboarding
        log.error(error.localizedDescription)
      }
    }
  }
}
