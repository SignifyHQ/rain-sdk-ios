import Foundation
import CardDomain

public protocol CardAPIProtocol {
  func getListCard() async throws -> [APICard]
  func getCard(cardID: String, sessionID: String) async throws -> APICard
  func lockCard(cardID: String, sessionID: String) async throws -> APICard
  func unlockCard(cardID: String, sessionID: String) async throws -> APICard
  func orderPhysicalCard(address: PhysicalCardAddressEntity, sessionID: String) async throws -> APICard
  func verifyCVVCode(verifyRequest: APIVerifyCVVRequest, cardID: String, sessionID: String) async throws -> APIVerifyCVVResponse
  func setPin(requestParam: APISetPinRequest, cardID: String, sessionID: String) async throws -> APICard
}
