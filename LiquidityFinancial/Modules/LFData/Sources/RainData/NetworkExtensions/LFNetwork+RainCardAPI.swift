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
  
  public func getCardOrders() async throws -> [APIRainCardOrder] {
    try await request(
      RainCardRoute.getCardOrders,
      target: [APIRainCardOrder].self,
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
  
  public func orderPhysicalCardWithApproval(parameters: APIRainOrderCardParameters) async throws -> APIRainCardOrder {
    try await request(
      RainCardRoute.orderPhysicalCardWithApproval(parameters: parameters),
      target: APIRainCardOrder.self,
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
  
  public func closeCard(cardID: String) async throws -> APIRainCard {
    try await request(
      RainCardRoute.closeCard(cardID: cardID),
      target: APIRainCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func lockCard(cardID: String) async throws -> APIRainCard {
    try await request(
      RainCardRoute.lockCard(cardID: cardID),
      target: APIRainCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func unlockCard(cardID: String) async throws -> APIRainCard {
    try await request(
      RainCardRoute.unlockCard(cardID: cardID),
      target: APIRainCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func cancelOrder(cardID: String) async throws -> APIRainCardOrder {
    try await request(
      RainCardRoute.cancelOrder(cardID: cardID),
      target: APIRainCardOrder.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getSecretCardInformation(sessionID: String, cardID: String) async throws -> APIRainSecretCardInformation {
    try await request(
      RainCardRoute.getSecretCardInfomation(sessionID: sessionID, cardID: cardID),
      target: APIRainSecretCardInformation.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createVirtualCard() async throws -> APIRainCard {
    try await request(
      RainCardRoute.createVirtualCard,
      target: APIRainCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
