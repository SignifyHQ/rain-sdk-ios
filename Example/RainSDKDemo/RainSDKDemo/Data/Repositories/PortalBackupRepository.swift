import Foundation
import PortalSwift

/// Portal wallet recovery previously pulled the encrypted backup share from the Liquidity
/// Financial proxy (`GET /v1/portal/backup`). The Rain dev API has no equivalent yet — backup/
/// recovery is slated to move behind the wallet-provider endpoint
/// (`POST /v1/issuing/users/{userId}/wallet`), which is not live.
///
/// This repository is kept as an inert seam: `fetchBackup` now throws a clear "unavailable"
/// error instead of calling a dead endpoint, so callers surface the state to the user.
final class PortalBackupRepository {
  init(client: APIClient? = nil) {}

  /// Always throws: wallet recovery is not yet available via the Rain API.
  func fetchBackup(backupMethod: String) async throws -> PortalBackupResponse {
    throw NSError(
      domain: "Recover",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey:
        "Wallet recovery is not yet available via the Rain API (pending the wallet-provider endpoint)."]
    )
  }
}
