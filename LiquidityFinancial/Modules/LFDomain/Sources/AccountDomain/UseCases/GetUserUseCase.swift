import Foundation

public final class GetUserUseCase: GetUserUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(
    repository: AccountRepositoryProtocol
  ) {
    self.repository = repository
  }

  public func execute() async throws -> LFUser {
    try await repository.getUser()
  }
}
