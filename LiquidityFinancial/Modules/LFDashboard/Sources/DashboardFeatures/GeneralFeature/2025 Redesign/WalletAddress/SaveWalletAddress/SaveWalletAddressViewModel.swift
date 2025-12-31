import LFLocalizable
import Factory
import AccountData
import AccountDomain
import SwiftUI
import LFUtilities
import LFStyleGuide

@MainActor
class SaveWalletAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @Published var shouldDismiss: Bool = false
  
  @Published var walletNickname: String = .empty
  @Published var showIndicator: Bool = false
  @Published var inlineMessage: String?
  @Published var toastData: ToastData?

  let walletAddress: String
  let accountId: String

  var isActionAllowed: Bool {
    !walletNickname.trimWhitespacesAndNewlines().isEmpty
  }

  init(accountId: String, walletAddress: String) {
    self.accountId = accountId
    self.walletAddress = walletAddress
  }
}

// MARK: Handle Interactions
extension SaveWalletAddressViewModel {
  func onSaveButtonTap() {
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
        toastData = .init(type: .success, title: L10N.Common.EnterNicknameOfWallet.walletWasSaved)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.shouldDismiss = true
        }
      } catch {
        self.handleAPIError(error)
      }
    }
  }
}

// MARK: - Helpers
private extension SaveWalletAddressViewModel {
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
