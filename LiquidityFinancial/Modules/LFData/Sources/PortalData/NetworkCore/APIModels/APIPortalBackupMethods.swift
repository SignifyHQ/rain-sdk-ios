import Foundation
import PortalDomain

public struct APIPortalBackupMethods: PortalBackupMethodsEntity, Decodable {
  public let backupMethods: [String]
}
