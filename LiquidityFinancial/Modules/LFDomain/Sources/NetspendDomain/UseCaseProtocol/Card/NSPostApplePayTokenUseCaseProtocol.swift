import Foundation

public protocol NSPostApplePayTokenUseCaseProtocol {
  func execute(
    sessionId: String,
    cardId: String,
    bodyData: [String: Any]
  ) async throws -> PostApplePayTokenEntity
}
