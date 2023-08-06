import Foundation
import Factory
import LFNetwork
import NetSpendDomain

extension Container {
  public var externalFundingAPI: Factory<NSExternalFundingAPIProtocol> {
    self {
      LFNetwork<NSExternalFundingRoute>()
    }
  }
  
  public var externalFundingRepository: Factory<NSExternalFundingRepositoryProtocol> {
    self {
      NSExternalFundingRepository(externalFundingAPI: self.externalFundingAPI.callAsFunction())
    }
  }
}
