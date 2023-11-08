import Foundation

public class NSGetAccountLimitsUseCase: NSGetAccountLimitsUseCaseProtocol {
  
  private let repository: NSAccountRepositoryProtocol
  
  public init(repository: NSAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> any NSAccountLimitsEntity {
    try await self.repository.getAccountLimits()
  }
}
