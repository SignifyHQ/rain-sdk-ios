import Foundation

public protocol ChangePasswordUseCaseProtocol {
  func execute(oldPassword: String, newPassword: String) async throws
}
