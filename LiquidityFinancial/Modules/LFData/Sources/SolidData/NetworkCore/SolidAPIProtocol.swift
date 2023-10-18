import BankDomain

public protocol SolidAPIProtocol {
  func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse
}
