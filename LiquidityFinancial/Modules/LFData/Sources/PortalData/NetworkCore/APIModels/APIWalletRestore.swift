import Foundation
import PortalDomain

public struct APIWalletRestore: WalletRestoreEntitiy, Codable {
  public let backupMethod: String
  public let cipherText: String
}
