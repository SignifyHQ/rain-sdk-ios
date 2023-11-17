import Foundation

public final class RequestMigrationStatusUseCase: RequestMigrationStatusUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> MigrationStatusEntity {
    try await repository.requestMigration()
  }
}
