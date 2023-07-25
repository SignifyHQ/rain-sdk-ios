import Foundation
import Factory
import OnboardingDomain
import LFNetwork
import OnboardingData
import LFAccountOnboarding
import DataUtilities
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
