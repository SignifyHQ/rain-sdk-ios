import Foundation

public final class CreatePasswordUseCase: CreatePasswordUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(password: String) async throws {
    try await repository.createPassword(password: password)
  }
}
