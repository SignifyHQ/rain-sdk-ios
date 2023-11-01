import Foundation

public protocol SolidGetAccountsUseCaseProtocol {
  func execute() async throws -> [SolidAccountEntity]
}
