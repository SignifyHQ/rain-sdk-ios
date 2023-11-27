import Foundation

// sourcery: AutoMockable
public protocol NSCardAPIProtocol {
  func getListCard() async throws -> [NSAPICard]
  func createCard(sessionID: String) async throws -> NSAPICard
  func getCard(cardID: String, sessionID: String) async throws -> NSAPICard
  func lockCard(cardID: String, sessionID: String) async throws -> NSAPICard
  func unlockCard(cardID: String, sessionID: String) async throws -> NSAPICard
  func closeCard(reason: CloseCardReasonParameters, cardID: String, sessionID: String) async throws -> NSAPICard
  func orderPhysicalCard(address: AddressCardParameters, sessionID: String) async throws -> NSAPICard
  func verifyCVVCode(verifyRequest: VerifyCVVCodeParameters, cardID: String, sessionID: String) async throws -> APIVerifyCVVCode
  func setPin(requestParam: APISetPinRequest, cardID: String, sessionID: String) async throws -> NSAPICard
  func getApplePayToken(sessionId: String, cardId: String) async throws -> APIGetApplePayToken
  func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> APIPostApplePayToken
}
