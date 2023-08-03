import Foundation

public protocol CardAPIProtocol {
  func getListCard() async throws -> [APICard]
  func getCard(cardID: String, sessionID: String) async throws -> APICard
  func lockCard(cardID: String, sessionID: String) async throws -> APICard
  func unlockCard(cardID: String, sessionID: String) async throws -> APICard
  func orderPhysicalCard(address: AddressCardParameters, sessionID: String) async throws -> APICard
  func verifyCVVCode(verifyRequest: VerifyCVVCodeParameters, cardID: String, sessionID: String) async throws -> APIVerifyCVVCode
  func setPin(requestParam: APISetPinRequest, cardID: String, sessionID: String) async throws -> APICard
  func getApplePayToken(sessionId: String, cardId: String) async throws -> APIGetApplePayToken
  func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> APIPostApplePayToken
}
