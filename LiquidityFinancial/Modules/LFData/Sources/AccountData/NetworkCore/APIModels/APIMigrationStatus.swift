import AccountDomain

public struct APIMigrationStatus: MigrationStatusEntity, Decodable {
  public var liquidityUserId: String?
  public var migrationNeeded: Bool
  public var migrationRequested: Bool
  public var migrated: Bool
}
