import Foundation

public final class DisableMFAUseCase: DisableMFAUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(code: String) async throws -> DisableMFAEntity {
    try await repository.disableMFA(code: code)
  }
}
