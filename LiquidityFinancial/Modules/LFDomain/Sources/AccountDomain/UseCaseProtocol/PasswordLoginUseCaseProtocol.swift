import Foundation

public protocol PasswordLoginUseCaseProtocol {
  func execute(password: String) async throws -> PasswordLoginTokensEntity
}
