import Foundation
import Factory
import ZerohashDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var zerohashAPI: Factory<ZerohashAPIProtocol> {
    self {
      LFCoreNetwork<ZerohashRoute>()
    }
  }
  
  public var zerohashRepository: Factory<ZerohashRepositoryProtocol> {
    self { ZerohashRepository(zerohashAPI: self.zerohashAPI.callAsFunction()) }
  }
  
  public var zerohashAccountAPI: Factory<ZerohashAccountAPIProtocol> {
    self {
      LFCoreNetwork<ZerohashAccountRoute>()
    }
  }
  
  public var zerohashAccountRepository: Factory<ZerohashAccountRepositoryProtocol> {
    self { ZerohashAccountRepository(accountAPI: self.zerohashAccountAPI.callAsFunction()) }
  }
  
}
