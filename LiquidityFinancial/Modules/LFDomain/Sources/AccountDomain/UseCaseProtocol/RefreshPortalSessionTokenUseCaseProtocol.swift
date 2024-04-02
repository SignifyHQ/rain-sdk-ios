import Foundation

public protocol RefreshPortalSessionTokenUseCaseProtocol {
  func execute() async throws -> PortalSessionTokenEntity
}
