import Foundation
import Factory
import BankDomain
import CoreNetwork

extension Container {
  public var nsAccountAPI: Factory<NSAccountAPIProtocol> {
    self {
      LFCoreNetwork<NSAccountRoute>()
    }
  }
  
  public var nsAccountRepository: Factory<NSAccountRepositoryProtocol> {
    self {
      NSAccountRepository(accountAPI: self.nsAccountAPI.callAsFunction())
    }
  }
}
