import Foundation
import Factory
import SolidDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var solidOnboardingAPI: Factory<SolidOnboardingAPIProtocol> {
    self {
      LFCoreNetwork<SolidOnboardingRoute>()
    }
  }
  
  public var solidOnboardingRepository: Factory<SolidOnboardingRepositoryProtocol> {
    self { SolidOnboardingRepository(onboardingAPI: self.solidOnboardingAPI.callAsFunction()) }
  }
}
