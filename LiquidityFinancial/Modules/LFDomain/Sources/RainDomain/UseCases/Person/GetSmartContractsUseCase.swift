import Foundation

public class GetSmartContractsUseCase: GetSmartContractsUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [RainSmartContractEntity] {
    try await repository.getSmartContracts()
  }
}
