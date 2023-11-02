import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidCardAPIProtocol where R == SolidCardRoute {
  
  public func getListCard() async throws -> [APISolidCard] {
    let response = try await request(
      SolidCardRoute.listCard,
      target: APIListObject<APISolidCard>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return response.data
  }
}
