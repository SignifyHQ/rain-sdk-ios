import Foundation

// sourcery: AutoMockable
public protocol MigrationStatusEntity {
  var liquidityUserId: String? { get }
  var migrationNeeded: Bool { get }
  var migrationRequested: Bool { get }
  var migrated: Bool { get }
}
