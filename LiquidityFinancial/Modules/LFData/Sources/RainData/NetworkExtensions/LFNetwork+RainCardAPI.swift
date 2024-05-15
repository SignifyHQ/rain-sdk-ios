import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: RainCardAPIProtocol where R == RainCardRoute {
  public func getCards() async throws -> [APIRainCard] {
    try await request(
      RainCardRoute.getCards,
      target: [APIRainCard].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func orderPhysicalCard(parameters: APIRainOrderCardParameters) async throws -> APIRainCard {
    try await request(
      RainCardRoute.orderPhysicalCard(parameters: parameters),
      target: APIRainCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func activatePhysicalCard(cardID: String, parameters: APIRainActivateCardParameters) async throws {
    try await requestNoResponse(
      RainCardRoute.activatePhysicalCard(cardID: cardID, parameters: parameters),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
