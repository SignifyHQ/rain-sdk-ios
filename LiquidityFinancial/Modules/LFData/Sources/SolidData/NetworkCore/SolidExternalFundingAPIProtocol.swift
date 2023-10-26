import Foundation

// sourcery: AutoMockable
public protocol SolidExternalFundingAPIProtocol {
  func getLinkedSources(accountId: String) async throws -> [APISolidContact]
  func createDebitCardToken(accountID: String) async throws -> APISolidDebitCardToken
  func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse
  func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> APISolidContact
}
