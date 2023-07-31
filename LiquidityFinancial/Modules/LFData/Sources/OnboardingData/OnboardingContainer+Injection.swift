import Foundation
import Factory
import OnboardingDomain
import LFNetwork
import AuthorizationManager

extension Container {
  public var onboardingAPI: Factory<OnboardingAPIProtocol> {
    self {
      LFNetwork<OnboardingRoute>()
    }
  }
  
  public var onboardingRepository: Factory<OnboardingRepositoryProtocol> {
    self {
      OnboardingRepository(onboardingAPI: self.onboardingAPI.callAsFunction(), auth: self.authorizationManager.callAsFunction())
    }
  }
}
