import Foundation
import Factory
import OnboardingDomain
import CoreNetwork
import OnboardingData
import NetspendOnboarding
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
