import Foundation

public final class VerifyEmailUseCase: VerifyEmailUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(code: String) async throws {
    try await repository.verifyEmail(code: code)
  }
}
