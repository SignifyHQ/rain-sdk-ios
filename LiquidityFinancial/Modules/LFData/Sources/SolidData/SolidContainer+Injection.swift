import Factory
import SolidDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var solidAPI: Factory<SolidAPIProtocol> {
    self {
      LFCoreNetwork<SolidRoute>()
    }
  }
  
  public var solidLinkSourceRepository: Factory<LinkSourceRepositoryProtocol> {
    self {
      SolidLinkSourceRepository(solidAPI: self.solidAPI.callAsFunction())
    }
  }
}
