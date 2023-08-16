import Foundation
import Factory
import CoreNetwork
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
