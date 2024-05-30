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
  
  public var rainRewardAPI: Factory<RainRewardAPIProtocol> {
    self {
      LFCoreNetwork<RainRewardRoute>()
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
  
  public var rainRewardRepository: Factory<RainRewardRepositoryProtocol> {
    self {
      RainRewardRepository(
        rainRewardAPI: self.rainRewardAPI.callAsFunction()
      )
    }
  }
}
