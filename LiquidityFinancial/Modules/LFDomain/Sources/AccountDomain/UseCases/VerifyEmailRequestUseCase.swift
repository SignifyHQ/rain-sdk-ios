import Foundation

public final class VerifyEmailRequestUseCase: VerifyEmailRequestUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws {
    try await repository.verifyEmailRequest()
  }
}
