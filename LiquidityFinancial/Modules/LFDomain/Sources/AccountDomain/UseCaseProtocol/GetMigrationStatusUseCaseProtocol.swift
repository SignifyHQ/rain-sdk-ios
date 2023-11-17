import Foundation

public protocol GetMigrationStatusUseCaseProtocol {
  func execute() async throws -> MigrationStatusEntity
}
