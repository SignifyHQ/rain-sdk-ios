import Foundation

public protocol ResetPasswordUseCaseProtocol {
  func execute(password: String, token: String) async throws
}
