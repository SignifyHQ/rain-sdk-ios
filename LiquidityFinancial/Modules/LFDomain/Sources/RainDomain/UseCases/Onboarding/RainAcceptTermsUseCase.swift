import Foundation

public class RainAcceptTermsUseCase: RainAcceptTermsUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws {
    try await repository.acceptTerms()
  }
}
