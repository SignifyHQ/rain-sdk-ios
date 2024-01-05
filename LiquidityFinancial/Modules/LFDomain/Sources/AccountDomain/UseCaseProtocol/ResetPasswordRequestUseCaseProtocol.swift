import Foundation

public protocol ResetPasswordRequestUseCaseProtocol {
  func execute(phoneNumber: String) async throws
}
