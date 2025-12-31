import Foundation

// sourcery: AutoMockable
public protocol PortalBackupMethodsEntity {
    var backupMethods: [String] { get }
    var lastAdded: LastAddedBackupMethodEntity? { get }
}

public protocol LastAddedBackupMethodEntity {
    var backupMethod: String? { get }
    var createdAt: String? { get }
    var updatedAt: String? { get }
}
