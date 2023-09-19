import Foundation

public protocol LoginUseCaseProtocol {
  func execute(phoneNumber: String, otpCode: String, lastID: String) async throws -> AccessTokens
}
