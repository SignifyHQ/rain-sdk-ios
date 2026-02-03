import Foundation
import RainSDK
import PortalSwift

/// ViewModel for the recover wallet popup. Shown after opening Portal Withdraw (access token is entered on entry view).
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
    if method == .Password && recoverPassword.isEmpty {
      recoverError = NSError(domain: "Recover", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password is required."])
      return
    }
    guard let token = AuthTokenStorage.getToken(), !token.isEmpty else {
      recoverError = NSError(
        domain: "Recover",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Access token is required for recovery. Enter your access token on the Portal Withdraw entry screen first, then try Recover again."]
      )
      return
    }
    isRecovering = true
    recoverError = nil
    do {
      let backup = try await backupRepository.fetchBackup(backupMethod: method.rawValue)
      try await sdkService.recover(
        backupMethod: method,
        password: method == .Password ? recoverPassword : nil,
        cipherText: backup.cipherText
      )
      dismissRecoverSheet()
    } catch {
      recoverError = error
    }
    isRecovering = false
  }
}
