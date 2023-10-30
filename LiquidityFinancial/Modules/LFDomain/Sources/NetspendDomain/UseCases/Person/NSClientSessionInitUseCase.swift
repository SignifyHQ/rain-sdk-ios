import Foundation

public class NSClientSessionInitUseCase: NSClientSessionInitUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> NSJwkTokenEntity {
    try await repository.clientSessionInit()
  }
}
