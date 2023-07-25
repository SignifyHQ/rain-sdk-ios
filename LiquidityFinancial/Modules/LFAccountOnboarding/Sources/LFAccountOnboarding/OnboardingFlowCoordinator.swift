import SwiftUI
import LFUtilities
import Combine
import Factory
import NetSpendData
import OnboardingData
import OnboardingDomain

public protocol OnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<OnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: OnboardingFlowCoordinator.Route)
}

public class OnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  public enum Route: Int {
    case initial
    case phone
    case welcome
    case kycReview
    case dashboard
  }
  
  @Injected(\.authorizationManager) var authorizationManager
  @Injected(\.userDataManager) var userDataManager
  @Injected(\.onboardingRepository) var onboardingRepository
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  public init() {
    self.routeSubject = .init(.initial)
  }
  
  public func set(route: Route) {
    guard routeSubject.value != route else { return }
    log.info("OnboardingFlowCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  public func routeUser() {
    if authorizationManager.isTokenValid() {
      getCurrentState()
    } else {
      routeSubject.value = .phone
    }
  }

  func getCurrentState() {
    Task { @MainActor in
      do {
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID)
        if onboardingState.missingSteps.isEmpty {
          routeSubject.value = .dashboard
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            let workflowsMissingStep = WorkflowsMissingStep.allCases.map { $0.rawValue }
            if (onboardingState.missingSteps.first(where: { workflowsMissingStep.contains($0) }) != nil) {
              routeSubject.value = .kycReview
            } else {
              //TODO: Tony need review
              routeSubject.value = .dashboard
            }
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              routeSubject.value = .welcome
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              routeSubject.value = .kycReview
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
                //TODO:Tony
            } else if states.contains(OnboardingMissingStep.cardProvision) {
                //TODO:Tony
            }
          }
        }
      } catch {
        routeSubject.value = .phone
        log.error(error.localizedDescription)
      }
    }
  }
  
}
