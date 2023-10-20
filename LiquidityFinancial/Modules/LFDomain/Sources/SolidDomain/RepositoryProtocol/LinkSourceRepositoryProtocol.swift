import Foundation

// sourcery: AutoMockable
public protocol LinkSourceRepositoryProtocol {
  func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity
  func linkPlaid(accountId: String, token: String, plaidAccountId: String) async throws -> any SolidContactEntity
}
