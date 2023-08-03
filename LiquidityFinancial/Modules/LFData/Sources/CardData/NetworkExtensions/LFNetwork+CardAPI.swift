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
  
  public func orderPhysicalCard(address: AddressCardParameters, sessionID: String) async throws -> APICard {
    return try await request(
      CardRoute.orderPhysicalCard(address, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func verifyCVVCode(verifyRequest: VerifyCVVParameters, cardID: String, sessionID: String) async throws -> APIVerifyCVVResponse {
    let parameters = VerifyCVVCodeParameters(
      verificationType: verifyRequest.verificationType,
      encryptedData: verifyRequest.encryptedData
    )
    return try await request(
      CardRoute.verifyCVVCode(parameters, cardID, sessionID),
      target: APIVerifyCVVResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func setPin(requestParam: APISetPinRequest, cardID: String, sessionID: String) async throws -> APICard {
    let parameters = SetPinParameters(verifyId: requestParam.verifyId, encryptedData: requestParam.encryptedData)
    return try await request(
      CardRoute.setPin(parameters, cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getApplePayToken(sessionId: String, cardId: String) async throws -> APIGetApplePayToken {
    return try await request(
      CardRoute.getApplyPayToken(cardId: cardId, sessionId: sessionId),
      target: APIGetApplePayToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> APIPostApplePayToken {
    return try await request(
      CardRoute.postApplyPayToken(cardId: cardId, sessionId: sessionId, bodyData: bodyData),
      target: APIPostApplePayToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
