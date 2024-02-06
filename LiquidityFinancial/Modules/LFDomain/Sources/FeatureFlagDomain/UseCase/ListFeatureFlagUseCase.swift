import Foundation

public class ListFeatureFlagUseCase: ListFeatureFlagUseCaseProtocol {
  
  private let repository: FeatureFlagRepositoryProtocol
  
  public init(repository: FeatureFlagRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> ListFeatureFlagEntity {
    return try await repository.list()
  }
  
}
