import Foundation

public class RainOrderPhysicalCardWithApprovalUseCase: RainOrderPhysicalCardWithApprovalUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: RainOrderCardParametersEntity) async throws -> RainCardOrderEntity {
    try await repository.orderPhysicalCardWithApproval(parameters: parameters)
  }
}
