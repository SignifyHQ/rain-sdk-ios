import Foundation

public class ZeroHashUserCase: ZeroHashUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> ZeroHashAccount {
    return try await repository.createZeroHashAccount()
  }
  
}
