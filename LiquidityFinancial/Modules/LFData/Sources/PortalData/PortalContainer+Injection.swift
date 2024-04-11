import Factory
import CoreNetwork
import AuthorizationManager
import PortalDomain
import Services

@MainActor
extension Container {
  public var portalAPI: Factory<PortalAPIProtocol> {
    self {
      LFCoreNetwork<PortalRoute>()
    }
  }
  
  public var portalRepository: Factory<PortalRepositoryProtocol> {
    self {
      PortalRepository(
        portalAPI: self.portalAPI.callAsFunction(),
        portalService: self.portalService.callAsFunction()
      )
    }
  }
}
