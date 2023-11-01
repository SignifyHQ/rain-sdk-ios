import Foundation

public protocol SolidGetLinkedSourcesUseCaseProtocol {
  func execute(accountID: String) async throws -> [SolidContactEntity]
}
