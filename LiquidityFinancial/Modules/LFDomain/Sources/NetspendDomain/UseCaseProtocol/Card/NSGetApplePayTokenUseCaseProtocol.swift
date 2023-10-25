import Foundation

public protocol NSGetApplePayTokenUseCaseProtocol {
  func execute(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity
}
