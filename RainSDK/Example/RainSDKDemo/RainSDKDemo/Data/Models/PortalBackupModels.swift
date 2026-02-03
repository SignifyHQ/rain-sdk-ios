import Foundation

/// Response for GET /v1/portal/backup (restoreWallet).
/// Used to fetch cipher text before calling Portal recover.
struct PortalBackupResponse: Decodable {
  public let backupMethod: String
  public let cipherText: String
}
