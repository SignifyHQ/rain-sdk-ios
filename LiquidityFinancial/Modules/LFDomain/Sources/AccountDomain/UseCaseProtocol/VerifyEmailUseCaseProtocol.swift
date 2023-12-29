import Foundation

public protocol VerifyEmailUseCaseProtocol {
  func execute(code: String) async throws
}
