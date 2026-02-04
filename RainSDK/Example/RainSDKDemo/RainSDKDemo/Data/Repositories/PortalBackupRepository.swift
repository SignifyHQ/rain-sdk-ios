import Foundation
import PortalSwift

/// Repository for GET /v1/portal/backup. Fetches backup (cipher text) before Portal recover.
final class PortalBackupRepository {
  private let client: APIClient

  init(client: APIClient? = nil) {
    if let client = client {
      self.client = client
    } else {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      self.client = APIClient(decoder: decoder)
    }
  }

  /// Fetches backup data (backupMethod + cipherText) from the API for recovery.
  /// - Parameter backupMethod: The selected recovery method (e.g. iCloud or Password); sent as query param.
  func fetchBackup(backupMethod: String) async throws -> PortalBackupResponse {
    let endpoint = Endpoint.restoreWallet(backupMethod: backupMethod)
    return try await client.request(endpoint, as: PortalBackupResponse.self)
  }
}
