import Foundation

public protocol CreatePortalWalletUseCaseProtocol {
  func execute() async throws -> String
}
