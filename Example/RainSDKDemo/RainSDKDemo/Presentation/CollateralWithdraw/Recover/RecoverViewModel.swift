import Foundation
import PortalSwift

/// ViewModel for the recover-wallet popup. Portal-only.
///
/// Portal recovery previously pulled the encrypted backup share from the Liquidity Financial
/// proxy (`GET /v1/portal/backup`). The Rain dev API has no equivalent yet — recovery is slated
/// to move behind the wallet-provider endpoint (`POST /v1/issuing/users/{userId}/wallet`), which
/// is not live. `performRecover` surfaces that state instead of calling a dead endpoint.
@MainActor
final class RecoverViewModel: ObservableObject {
  @Published var showRecoverChoiceSheet = false
  @Published var selectedRecoverMethod: BackupMethods?
  @Published var recoverPassword = ""
  @Published var recoverError: Error?
  @Published var isRecovering = false

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
    SampleLog.w("Portal.recover", "recovery unavailable — Rain wallet endpoint not yet live")
    recoverError = NSError(
      domain: "Recover",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey:
        "Wallet recovery is not yet available via the Rain API (pending the wallet-provider endpoint)."]
    )
  }
}
