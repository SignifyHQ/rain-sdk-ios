import Foundation
  
public class SolidCreatePinwheelTokenUseCase: SolidCreatePinwheelTokenUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String) async throws -> SolidExternalPinwheelTokenResponseEntity {
    try await self.repository.createPinwheelToken(accountId: accountId)
  }
}
