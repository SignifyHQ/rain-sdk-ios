import Foundation

public final class GetMigrationStatusUseCase: GetMigrationStatusUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> MigrationStatusEntity {
    try await repository.getMigrationStatus()
  }
}
