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
}
