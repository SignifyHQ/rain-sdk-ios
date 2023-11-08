import Foundation

public class SolidGetAccountLimitsUseCase: SolidGetAccountLimitsUseCaseProtocol {
  
  private let repository: SolidAccountRepositoryProtocol
  
  public init(repository: SolidAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> SolidAccountLimitsEntity? {
    let result = try await self.repository.getAccountLimits().first
    return result
  }
}
