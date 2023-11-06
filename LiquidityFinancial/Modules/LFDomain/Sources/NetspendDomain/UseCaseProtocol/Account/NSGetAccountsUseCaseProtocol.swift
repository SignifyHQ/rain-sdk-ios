import Foundation

public protocol NSGetAccountsUseCaseProtocol {
  func execute() async throws -> [NSAccountEntity]
}
