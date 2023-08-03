import Foundation
import Factory
import LFNetwork
import ExternalFundingDomain

extension Container {
  public var externalFundingAPI: Factory<ExternalFundingAPIProtocol> {
    self {
      LFNetwork<ExternalFundingRoute>()
    }
  }
  
  public var externalFundingRepository: Factory<ExternalFundingRepositoryProtocol> {
    self {
      ExternalFundingRepository(externalFundingAPI: self.externalFundingAPI.callAsFunction())
    }
  }
}
