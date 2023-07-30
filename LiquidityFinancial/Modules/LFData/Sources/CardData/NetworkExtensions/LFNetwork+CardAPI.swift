import Foundation
import DataUtilities
import LFNetwork
import LFUtilities

extension LFNetwork: CardAPIProtocol where R == CardRoute {
  public func getListCard() async throws -> [APICard] {
    return try await request(
      CardRoute.listCard,
      target: [APICard].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
