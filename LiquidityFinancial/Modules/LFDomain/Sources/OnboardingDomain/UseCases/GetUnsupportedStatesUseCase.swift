import Foundation

public class GetUnsupportedStatesUseCase: GetUnsupportedStatesUseCaseProtocol {
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: UnsupportedStateParametersEntity) async throws -> [UnsupportedStateEntity] {
    try await repository.getUnsupportedStates(parameters: parameters)
  }
}
