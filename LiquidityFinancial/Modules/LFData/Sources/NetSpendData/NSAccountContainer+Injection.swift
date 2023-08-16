import Foundation
import Factory
import NetSpendDomain
import CoreNetwork

extension Container {
  public var nsAccountAPI: Factory<NSAccountAPIProtocol> {
    self {
      LFNetwork<NSAccountRoute>()
    }
  }
  
  public var nsAccountRepository: Factory<NSAccountRepositoryProtocol> {
    self {
      NSAccountRepository(accountAPI: self.nsAccountAPI.callAsFunction())
    }
  }
}
