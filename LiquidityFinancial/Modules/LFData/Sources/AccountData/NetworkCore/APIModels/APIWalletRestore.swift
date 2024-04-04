import Foundation
import AccountDomain

public struct APIWalletRestore: WalletRestoreEntitiy, Codable {
  public let backupMethod: String
  public let cipherText: String
}
