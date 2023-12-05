import Foundation

// sourcery: AutoMockable
public protocol SolidExternalFundingRepositoryProtocol {
  func getLinkedSources(accountID: String) async throws -> [SolidContactEntity]
  func createDebitCardToken(accountID: String) async throws -> SolidDebitCardTokenEntity
  func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity
  func linkPlaid(accountId: String, token: String, plaidAccountId: String) async throws -> any SolidContactEntity
  func unlinkContact(id: String) async throws -> SolidUnlinkContactResponseEntity
  func getWireTransfer(accountId: String) async throws -> SolidWireTransferResponseEntity
  func newTransaction(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> SolidExternalTransactionResponseEntity
  func estimateDebitCardFee(accountId: String, contactId: String, amount: Double) async throws -> SolidDebitCardTransferFeeResponseEntity
  func createPinwheelToken(accountId: String) async throws -> SolidExternalPinwheelTokenResponseEntity
  func cancelACHTransaction(liquidityTransactionID: String) async throws -> SolidExternalTransactionResponseEntity
}
