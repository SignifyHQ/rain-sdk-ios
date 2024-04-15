import Factory
import CoreNetwork
import AuthorizationManager
import RainDomain

// MARK: - RainOnboarding
extension Container {
  public var rainAPI: Factory<RainAPIProtocol> {
    self {
      LFCoreNetwork<RainOnboardingRoute>()
    }
  }
  
  public var rainRepository: Factory<RainRepositoryProtocol> {
    self {
      RainRepository(
        rainAPI: self.rainAPI.callAsFunction()
      )
    }
  }
}
