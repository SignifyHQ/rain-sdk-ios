import Foundation

public protocol CardRepositoryProtocol {
  func getListCard() async throws -> [CardEntity]
  func lockCard(cardID: String, sessionID: String) async throws -> CardEntity
  func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity
}
