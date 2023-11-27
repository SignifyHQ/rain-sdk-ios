import Foundation

public protocol NSLockCardUseCaseProtocol {
  func execute(cardID: String, sessionID: String) async throws -> NSCardEntity
}
