import Foundation
import Factory
import OnboardingDomain
import CoreNetwork
import OnboardingData
import LFAccountOnboarding
import NetworkUtilities
import AuthorizationManager
import NetSpendData

@MainActor
extension Container {
  
  //Coordinator
  var coordinator: Factory<AppCoordinatorProtocol> {
    self {
      AppCoordinator()
    }
  }

}
