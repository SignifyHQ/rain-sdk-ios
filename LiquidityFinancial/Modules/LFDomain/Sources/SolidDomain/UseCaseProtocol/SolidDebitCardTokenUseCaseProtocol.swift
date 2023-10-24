import Foundation

public protocol SolidDebitCardTokenUseCaseProtocol {
  func execute(accountID: String) async throws -> SolidDebitCardTokenEntity
}
