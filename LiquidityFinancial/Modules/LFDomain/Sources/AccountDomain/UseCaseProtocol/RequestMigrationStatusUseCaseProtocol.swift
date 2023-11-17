import Foundation

public protocol RequestMigrationStatusUseCaseProtocol {
  func execute() async throws -> MigrationStatusEntity
}
