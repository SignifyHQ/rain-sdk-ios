import Foundation

public protocol CardUseCaseProtocol {
  func getListCard() async throws -> [CardEntity]
  func getCard(cardID: String, sessionID: String) async throws -> CardEntity
  func lockCard(cardID: String, sessionID: String) async throws -> CardEntity
  func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity
  func orderPhysicalCard(address: PhysicalCardAddressEntity, sessionID: String) async throws -> CardEntity
}
