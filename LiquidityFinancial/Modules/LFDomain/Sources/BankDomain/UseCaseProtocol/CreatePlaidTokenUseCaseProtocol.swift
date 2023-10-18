import Foundation

public protocol CreatePlaidTokenUseCaseProtocol {
  func execute(accountId: String) async throws -> CreatePlaidTokenResponseEntity
}
