import LFLocalizable
import Factory
import AccountData
import AccountDomain
import SwiftUI
import LFUtilities
import LFStyleGuide
import CodeScanner

@MainActor
class CreateNewWalletAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @Published var shouldDismiss: Bool = false
  
  @Published var walletAddress: String = .empty
  @Published var walletNickname: String = .empty
  @Published var showIndicator: Bool = false
  @Published var inlineMessage: String?
  @Published var toastData: ToastData?
  @Published var isShowingScanner: Bool = false
  
  var isActionAllowed: Bool {
    !walletNickname.trimWhitespacesAndNewlines().isEmpty
    && !walletAddress.trimWhitespacesAndNewlines().isEmpty
  }

  let accountId: String
  
  init(accountId: String) {
    self.accountId = accountId
  }
}

// MARK: Handle Interactions
extension CreateNewWalletAddressViewModel {
  func onContinueButtonTap(callback: (() -> Void)? = nil) {
    guard !walletAddress.isEmpty,
          !walletNickname.isEmpty
    else {
      return
    }

    showIndicator = true
    
    Task { @MainActor in
      defer {
        showIndicator = false
      }
      do {
        let walletAddress = try await accountRepository.createWalletAddresses(
          address: walletAddress,
          nickname: walletNickname
        )
        accountDataManager.addOrEditWalletAddress(walletAddress)
        callback?()
      } catch {
        self.handleAPIError(error)
      }
    }
  }
  
  func clearValue() {
    walletAddress = .empty
  }
  
  func onScanButtonTap() {
    isShowingScanner = true
  }
  
  func handleScan(result: Result<ScanResult, ScanError>) {
    isShowingScanner = false
    switch result {
    case let .success(result):
      walletAddress = result.string.parseWalletAddress()
    case let .failure(error):
      log.error("Scanning failed: \(error.userFriendlyMessage)")
    }
  }
}

// MARK: - Helpers
private extension CreateNewWalletAddressViewModel {
  func handleAPIError(_ error: Error) {
    guard let code = error.asErrorObject?.code else {
      toastData = .init(type: .error, title: error.userFriendlyMessage)
      return
    }
    switch code {
    case Constants.ErrorCode.duplicatedWalletNickname.value:
      inlineMessage = L10N.Common.EnterNicknameOfWallet.NameExist.inlineError
    default:
      toastData = .init(type: .error, title: error.userFriendlyMessage)
    }
  }
}
