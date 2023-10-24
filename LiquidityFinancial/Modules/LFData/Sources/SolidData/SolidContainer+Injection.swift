import Factory
import SolidDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var solidAPI: Factory<SolidAPIProtocol> {
    self {
      LFCoreNetwork<SolidRoute>()
    }
  }
  
  public var solidLinkSourceRepository: Factory<LinkSourceRepositoryProtocol> {
    self {
      SolidLinkSourceRepository(solidAPI: self.solidAPI.callAsFunction())
    }
  }
  
}

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

extension Container {
  
  public var solidAccountAPI: Factory<SolidAccountAPIProtocol> {
    self {
      LFCoreNetwork<SolidAccountRoute>()
    }
  }
  
  public var solidAccountRepository: Factory<SolidAccountRepositoryProtocol> {
    self { SolidAccountRepository(accountAPI: self.solidAccountAPI.callAsFunction()) }
  }
}
