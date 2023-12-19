import Factory
import OnboardingDomain
import CoreNetwork
import OnboardingData
import NetworkUtilities
import AuthorizationManager

@MainActor
extension Container {
  
  //Coordinator
  var coordinator: Factory<AppCoordinatorProtocol> {
    self {
      AppCoordinator()
    }.singleton
  }

}
