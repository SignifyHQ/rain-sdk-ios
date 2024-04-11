import Foundation

public protocol WalletBackupUseCaseProtocol {
  func execute(cipher: String, method: String) async throws
}
