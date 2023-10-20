import Foundation

public protocol PlaidLinkUseCaseProtocol {
  func execute(accountId: String, token: String, plaidAccountId: String) async throws -> any SolidContactEntity
}
