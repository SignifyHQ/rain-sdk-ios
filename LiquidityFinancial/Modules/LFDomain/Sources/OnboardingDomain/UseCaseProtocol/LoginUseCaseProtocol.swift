import Foundation

public protocol LoginUseCaseProtocol {
  func execute(phoneNumber: String, code: String) async throws -> AccessTokens
}
