import CoreNetwork
import Factory
import MeshDomain
import Services

@MainActor
extension Container {
  public var meshAPI: Factory<MeshAPIProtocol> {
    self {
      LFCoreNetwork<MeshRoute>()
    }
  }
  
  public var meshRepository: Factory<MeshRepositoryProtocol> {
    self {
      MeshRepository(
        meshAPI: self.meshAPI.callAsFunction(),
        meshService: self.meshService.callAsFunction()
      )
    }
  }
}
