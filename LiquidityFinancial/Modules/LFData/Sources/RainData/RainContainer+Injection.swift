import Factory
import CoreNetwork
import AuthorizationManager
import RainDomain

// MARK: - RainOnboarding
extension Container {
  public var rainOnboardingAPI: Factory<RainOnboardingAPIProtocol> {
    self {
      LFCoreNetwork<RainOnboardingRoute>()
    }
  }
  
  public var rainOnboardingRepository: Factory<RainOnboardingRepositoryProtocol> {
    self {
      RainOnboardingRepository(
        onboardingAPI: self.rainOnboardingAPI.callAsFunction()
      )
    }
  }
}
