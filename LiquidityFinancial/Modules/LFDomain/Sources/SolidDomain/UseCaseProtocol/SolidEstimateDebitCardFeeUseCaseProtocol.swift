import Foundation

public protocol SolidEstimateDebitCardFeeUseCaseProtocol {
  func execute(accountId: String, contactId: String, amount: Double) async throws -> SolidDebitCardTransferFeeResponseEntity
}
