import Foundation

// sourcery: AutoMockable
public protocol NSCardRepositoryProtocol {
  func getListCard() async throws -> [NSCardEntity]
  func createCard(sessionID: String) async throws -> NSCardEntity
  func getCard(cardID: String, sessionID: String) async throws -> NSCardEntity
  func lockCard(cardID: String, sessionID: String) async throws -> NSCardEntity
  func unlockCard(cardID: String, sessionID: String) async throws -> NSCardEntity
  func closeCard(reason: CloseCardReasonEntity, cardID: String, sessionID: String) async throws -> NSCardEntity
  func orderPhysicalCard(address: AddressCardParametersEntity, sessionID: String) async throws -> NSCardEntity
  func verifyCVVCode(verifyRequest: VerifyCVVCodeParametersEntity, cardID: String, sessionID: String) async throws -> VerifyCVVCodeEntity
  func setPin(requestParam: SetPinRequestEntity, cardID: String, sessionID: String) async throws -> NSCardEntity
  func getApplePayToken(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity
  func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> PostApplePayTokenEntity
}
