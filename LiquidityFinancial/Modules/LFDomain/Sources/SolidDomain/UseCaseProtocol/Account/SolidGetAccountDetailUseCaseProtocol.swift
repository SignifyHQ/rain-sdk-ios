import Foundation

public protocol SolidGetAccountDetailUseCaseProtocol {
  func execute(id: String) async throws -> SolidAccountEntity
}
