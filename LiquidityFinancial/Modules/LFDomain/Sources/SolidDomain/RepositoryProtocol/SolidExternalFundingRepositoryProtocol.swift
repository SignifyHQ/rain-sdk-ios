import Foundation

// sourcery: AutoMockable
public protocol SolidExternalFundingRepositoryProtocol {
  func getLinkedSources(accountID: String) async throws -> [SolidContactEntity]
  func createDebitCardToken(accountID: String) async throws -> SolidDebitCardTokenEntity
  func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity
  func linkPlaid(accountId: String, token: String, plaidAccountId: String) async throws -> any SolidContactEntity
  func unlinkContact(id: String) async throws -> SolidUnlinkContactResponseEntity
  func getWireTransfer(accountId: String) async throws -> SolidWireTransferResponseEntity
}
