import Foundation

public protocol CardRepositoryProtocol {
  func getListCard() async throws -> [CardEntity]
  func getCard(cardID: String, sessionID: String) async throws -> CardEntity
  func lockCard(cardID: String, sessionID: String) async throws -> CardEntity
  func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity
  func orderPhysicalCard(address: AddressCardParametersEntity, sessionID: String) async throws -> CardEntity
  func verifyCVVCode(verifyRequest: VerifyCVVCodeParametersEntity, cardID: String, sessionID: String) async throws -> VerifyCVVCodeEntity
  func setPin(requestParam: SetPinRequestEntity, cardID: String, sessionID: String) async throws -> CardEntity
  func getApplePayToken(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity
  func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> PostApplePayTokenEntity
}
