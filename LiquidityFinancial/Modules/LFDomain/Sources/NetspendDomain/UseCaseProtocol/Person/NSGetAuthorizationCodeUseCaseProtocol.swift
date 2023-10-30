import Foundation

public protocol NSGetAuthorizationCodeUseCaseProtocol {
  func execute(sessionId: String) async throws -> AuthorizationCodeEntity
}
