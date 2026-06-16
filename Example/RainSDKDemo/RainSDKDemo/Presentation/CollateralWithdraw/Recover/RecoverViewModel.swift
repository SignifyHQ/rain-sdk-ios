import Foundation
import RainSDK
import PortalSwift

/// ViewModel for the recover wallet popup. Portal-only. Wallet recovery is currently
/// unavailable via the Rain dev API (the LF backup endpoint was removed), so `performRecover`
/// surfaces that state instead of fetching a backup share.
@MainActor
class RecoverViewModel: ObservableObject {
  private let sdkService: RainSDKService
  private let backupRepository: PortalBackupRepository

  @Published var showRecoverChoiceSheet: Bool = false
  @Published var selectedRecoverMethod: BackupMethods?
  @Published var recoverPassword: String = ""
  @Published var recoverError: Error?
  @Published var isRecovering: Bool = false

  init(
    sdkService: RainSDKService = .shared,
    backupRepository: PortalBackupRepository = PortalBackupRepository()
  ) {
    self.sdkService = sdkService
    self.backupRepository = backupRepository
  }

  func showRecoverSheet() {
    recoverError = nil
    selectedRecoverMethod = .Password
    recoverPassword = ""
    showRecoverChoiceSheet = true
  }

  func dismissRecoverSheet() {
    showRecoverChoiceSheet = false
    selectedRecoverMethod = nil
    recoverPassword = ""
    recoverError = nil
  }

  func selectRecoverMethod(_ method: BackupMethods) {
    selectedRecoverMethod = method
    recoverError = nil
  }

  func performRecover() async {
    guard let method = selectedRecoverMethod else { return }
    
    // Portal wallet recovery previously pulled the encrypted backup share from the Liquidity
    // Financial proxy (`GET /v1/portal/backup`). The Rain dev API has no equivalent yet —
    // recovery is slated to move behind the wallet-provider endpoint
    // (`POST /v1/issuing/users/{userId}/wallet`), which is not live. Surface that clearly
    // instead of calling a dead endpoint.
    _ = method
    recoverError = NSError(
      domain: "Recover",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey:
        "Wallet recovery is not yet available via the Rain API (pending the wallet-provider endpoint)."]
    )
  }
}
