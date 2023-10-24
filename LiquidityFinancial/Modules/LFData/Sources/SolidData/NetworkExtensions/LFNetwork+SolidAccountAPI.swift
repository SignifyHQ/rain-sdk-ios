import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidAccountAPIProtocol where R == SolidAccountRoute {
  
  public func getAccounts() async throws -> [APISolidAccount] {
    return try await request(
      SolidAccountRoute.getAccounts,
      target: [APISolidAccount].self,
      failure: LFErrorObject.self, decoder: .apiDecoder
    )
  }
  
}
