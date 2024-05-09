import Factory
import CoreNetwork
import AuthorizationManager
import RainDomain

// MARK: - RainOnboarding
extension Container {
  public var rainAPI: Factory<RainAPIProtocol> {
    self {
      LFCoreNetwork<RainRoute>()
    }
  }
  
  public var rainCardAPI: Factory<RainCardAPIProtocol> {
    self {
      LFCoreNetwork<RainCardRoute>()
    }
  }
  
  public var rainRepository: Factory<RainRepositoryProtocol> {
    self {
      RainRepository(
        rainAPI: self.rainAPI.callAsFunction()
      )
    }
  }
  
  public var rainCardRepository: Factory<RainCardRepositoryProtocol> {
    self {
      RainCardRepository(
        rainCardAPI: self.rainCardAPI.callAsFunction()
      )
    }
  }
}
