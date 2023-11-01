import Foundation
  
public class SolidEstimateDebitCardFeeUseCase: SolidEstimateDebitCardFeeUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, contactId: String, amount: Double) async throws -> SolidDebitCardTransferFeeResponseEntity {
    try await self.repository.estimateDebitCardFee(accountId: accountId, contactId: contactId, amount: amount)
  }
}
