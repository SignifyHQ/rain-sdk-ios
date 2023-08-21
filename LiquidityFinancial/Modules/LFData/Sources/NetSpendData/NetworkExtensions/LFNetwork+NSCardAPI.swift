import Foundation
import NetSpendDomain
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: NSCardAPIProtocol where R == NSCardRoute {
  public func getListCard() async throws -> [APICard] {
    try await request(
      NSCardRoute.listCard,
      target: [APICard].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getCard(cardID: String, sessionID: String) async throws -> APICard {
    try await request(
      NSCardRoute.card(cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> APICard {
    try await request(
      NSCardRoute.lock(cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> APICard {
    try await request(
      NSCardRoute.unlock(cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func orderPhysicalCard(address: AddressCardParameters, sessionID: String) async throws -> APICard {
    return try await request(
      NSCardRoute.orderPhysicalCard(address, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func verifyCVVCode(verifyRequest: VerifyCVVCodeParameters, cardID: String, sessionID: String) async throws -> APIVerifyCVVCode {
    return try await request(
      NSCardRoute.verifyCVVCode(verifyRequest, cardID, sessionID),
      target: APIVerifyCVVCode.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func setPin(requestParam: APISetPinRequest, cardID: String, sessionID: String) async throws -> APICard {
    let parameters = SetPinParameters(verifyId: requestParam.verifyId, encryptedData: requestParam.encryptedData)
    return try await request(
      NSCardRoute.setPin(parameters, cardID, sessionID),
      target: APICard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getApplePayToken(sessionId: String, cardId: String) async throws -> APIGetApplePayToken {
    return try await request(
      NSCardRoute.getApplyPayToken(cardId: cardId, sessionId: sessionId),
      target: APIGetApplePayToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> APIPostApplePayToken {
    return try await request(
      NSCardRoute.postApplyPayToken(cardId: cardId, sessionId: sessionId, bodyData: bodyData),
      target: APIPostApplePayToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
