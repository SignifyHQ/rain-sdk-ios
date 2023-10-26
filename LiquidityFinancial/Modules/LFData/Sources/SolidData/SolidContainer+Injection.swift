import Factory
import SolidDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var solidExternalFundingAPI: Factory<SolidExternalFundingAPIProtocol> {
    self {
      LFCoreNetwork<SolidExternalFundingRoute>()
    }
  }
  
  public var solidExternalFundingRepository: Factory<SolidExternalFundingRepositoryProtocol> {
    self {
      SolidExternalFundingRepository(solidExternalFundingAPI: self.solidExternalFundingAPI.callAsFunction())
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
