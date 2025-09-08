import Foundation

public class RainGetCardOrdersUseCase: RainGetCardOrdersUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [RainCardOrderEntity] {
    try await repository.getCardOrders()
  }
}
