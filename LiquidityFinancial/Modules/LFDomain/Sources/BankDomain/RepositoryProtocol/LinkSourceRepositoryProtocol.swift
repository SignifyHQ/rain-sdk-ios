import Foundation

public protocol LinkSourceRepositoryProtocol {
  func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity
}
