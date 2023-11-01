import Foundation
  
public class SolidGetWireTranferUseCase: SolidGetWireTranferUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String) async throws -> SolidWireTransferResponseEntity {
    try await self.repository.getWireTransfer(accountId: accountId)
  }
}
