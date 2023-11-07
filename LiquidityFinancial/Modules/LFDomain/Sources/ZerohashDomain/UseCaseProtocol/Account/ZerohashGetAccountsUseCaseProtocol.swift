import Foundation

public protocol ZerohashGetAccountsUseCaseProtocol {
  func execute() async throws -> [ZerohashAccountEntity]
}
