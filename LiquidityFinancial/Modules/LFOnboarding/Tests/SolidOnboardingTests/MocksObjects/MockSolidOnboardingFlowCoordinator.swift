import Combine
@testable import SolidOnboarding

class MockSolidOnboardingFlowCoordinator: SolidOnboardingFlowCoordinatorProtocol {
  var routeSubject = CurrentValueSubject<SolidOnboardingFlowCoordinator.Route, Never>(.initial)
  
  var routeUserCalled = false
  var setRouteCalled = false
  var apiFetchCurrentStateCalled = false
  var handlerOnboardingStepCalled = false
  var fetchUserReviewStatusCalled = false
  var forcedLogoutCalled = false
  var handlerOnboardingStepThrowError: Error?
  
  func routeUser() {
    routeUserCalled = true
  }
  
  func set(route: SolidOnboardingFlowCoordinator.Route) {
    setRouteCalled = true
  }
  
  func apiFetchCurrentState() async {
    apiFetchCurrentStateCalled = true
  }
  
  func handleOnboardingStep() async throws {
    if let error = handlerOnboardingStepThrowError {
      throw error
    }
    handlerOnboardingStepCalled = true
  }
  
  func fetchUserReviewStatus(needLoadMigration: Bool) async throws {
    fetchUserReviewStatusCalled = true
  }
  
  func forceLogout() {
    forcedLogoutCalled = true
  }
}
