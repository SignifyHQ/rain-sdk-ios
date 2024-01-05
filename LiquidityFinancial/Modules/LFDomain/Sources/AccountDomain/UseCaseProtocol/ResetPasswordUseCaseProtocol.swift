import Foundation

public protocol ResetPasswordUseCaseProtocol {
  func execute(phoneNumber: String, password: String, token: String) async throws
}
