import Foundation
import Factory
import CoreNetwork
import BankDomain

extension Container {
  public var externalFundingAPI: Factory<NSExternalFundingAPIProtocol> {
    self {
      LFCoreNetwork<NSExternalFundingRoute>()
    }
  }
  
  public var externalFundingRepository: Factory<NSExternalFundingRepositoryProtocol> {
    self {
      NSExternalFundingRepository(externalFundingAPI: self.externalFundingAPI.callAsFunction())
    }
  }
}
