import Foundation

public protocol NSGetCardUseCaseProtocol {
  func execute(cardID: String, sessionID: String) async throws -> CardEntity
}
