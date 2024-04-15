import Foundation

public class CreateRainAccountUseCase: CreateRainAccountUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: RainPersonParametersEntity) async throws -> RainPersonEntity {
    try await repository.createRainAccount(parameters: parameters)
  }
}
