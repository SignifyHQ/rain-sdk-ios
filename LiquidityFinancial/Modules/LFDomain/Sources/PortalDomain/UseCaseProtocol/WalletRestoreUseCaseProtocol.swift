import Foundation

public protocol WalletRestoreUseCaseProtocol {
  func execute(method: String) async throws -> WalletRestoreEntitiy
}
