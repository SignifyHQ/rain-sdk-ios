import Foundation

// sourcery: AutoMockable
public protocol LoginUseCaseProtocol {
  func execute(isNewAuth: Bool, parameters: LoginParametersEntity) async throws -> AccessTokensEntity
}
