import Foundation

public class ZeroHashUserCase: ZeroHashUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> ZeroHashAccount {
    return try await repository.createZeroHashAccount()
  }
  
}
