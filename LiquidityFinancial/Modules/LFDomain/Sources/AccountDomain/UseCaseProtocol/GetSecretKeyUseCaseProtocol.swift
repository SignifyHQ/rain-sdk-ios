import Foundation

public protocol GetSecretKeyUseCaseProtocol {
  func execute() async throws -> SecretKeyEntity
}
