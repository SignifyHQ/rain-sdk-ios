import Foundation
import PortalDomain

public struct APIPortalBackupMethods: PortalBackupMethodsEntity, Decodable {
  public let backupMethods: [String]
  
  // private backing property for protocol conformance
  private let _lastAdded: APILastAddedBackupMethod?
  
  // protocol-compliant computed property
  public var lastAdded: LastAddedBackupMethodEntity? {
    _lastAdded
  }
  
  // Decodable mapping
  enum CodingKeys: String, CodingKey {
    case backupMethods
    case _lastAdded = "lastAdded"
  }
}

public struct APILastAddedBackupMethod: LastAddedBackupMethodEntity, Decodable {
    public let backupMethod: String?
    public let createdAt: String?
    public let updatedAt: String?
}
