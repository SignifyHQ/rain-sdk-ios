import Foundation
import CardDomain
import DataUtilities
import LFNetwork
import LFUtilities

extension LFNetwork: CardAPIProtocol where R == CardRoute {
  public func getListCard() async throws -> [APICard] {
    try await request(
      CardRoute.listCard,
      target: [APICard].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getCard(cardID: String, sessionID: String) async throws -> APICard {
    try await request(
      CardRoute.card(cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> APICard {
    try await request(
      CardRoute.lock(cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> APICard {
    try await request(
      CardRoute.unlock(cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func orderPhysicalCard(address: PhysicalCardAddressEntity, sessionID: String) async throws -> APICard {
    return try await request(
      CardRoute.orderPhysicalCard(address, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
