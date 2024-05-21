import Foundation

public class RainCreateVirtualCardUseCase: RainCreateVirtualCardUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainCardEntity {
    try await repository.createVirtualCard()
  }
}
