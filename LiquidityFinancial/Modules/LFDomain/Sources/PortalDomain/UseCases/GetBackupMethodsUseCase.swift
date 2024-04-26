import Foundation

public final class GetBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> PortalBackupMethodsEntity {
    try await repository.getPortalBackupMethods()
  }
}
