import Foundation
import Factory
import NetSpendDomain
import CoreNetwork

extension Container {
  public var nsOnboardingAPI: Factory<NSOnboardingAPIProtocol> {
    self {
      LFCoreNetwork<NSOnboardingRoute>()
    }
  }
  
  public var nsOnboardingRepository: Factory<NSOnboardingRepositoryProtocol> {
    self {
      NSOnboardingRepository(onboardingAPI: self.nsOnboardingAPI.callAsFunction())
    }
  }
}
