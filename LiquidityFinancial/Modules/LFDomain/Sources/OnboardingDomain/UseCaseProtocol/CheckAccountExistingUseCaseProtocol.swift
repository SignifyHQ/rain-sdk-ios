import Foundation

// sourcery: AutoMockable
public protocol CheckAccountExistingUseCaseProtocol {
  func execute(parameters: CheckAccountExistingParametersEntity) async throws -> AccountExistingEntity
}
