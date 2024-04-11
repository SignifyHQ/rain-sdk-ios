import Foundation

// sourcery: AutoMockable
public protocol WalletRestoreEntitiy {
  var backupMethod: String { get }
  var cipherText: String { get }
}
