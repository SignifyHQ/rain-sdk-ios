import Foundation

public protocol SolidCreateExternalTransactionUseCaseProtocol {
  func execute(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> SolidExternalTransactionResponseEntity
}
