import Foundation

// sourcery: AutoMockable
public protocol SolidAPIProtocol {
  func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse
  func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> SolidContact
}
