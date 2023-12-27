import Foundation

public final class EnableMFAUseCase: EnableMFAUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(code: String) async throws -> EnableMFAEntity {
    try await repository.enableMFA(code: code)
  }
}
