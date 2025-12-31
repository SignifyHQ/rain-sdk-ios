import Foundation
import LFLocalizable
import Factory
import AccountData
import AccountDomain
import SwiftUI
import LFUtilities
import LFStyleGuide

@MainActor
class EditWalletAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var shouldDismiss: Bool = false
  
  @Published var walletNickname: String = .empty
  @Published var showSaveIndicator: Bool = false
  @Published var showDeleteIndicator: Bool = false
  @Published var toastData: ToastData?
  @Published var isShowingDeleteConfirmationSheet: Bool = false
  
  let wallet: APIWalletAddress
  let accountId: String

  var isActionAllowed: Bool {
    !walletNickname.trimWhitespacesAndNewlines().isEmpty
  }

  init(accountId: String, wallet: APIWalletAddress) {
    self.accountId = accountId
    self.wallet = wallet
    self.walletNickname = wallet.nickname ?? .empty
  }
}

// MARK: Handle Interactions
extension EditWalletAddressViewModel {
  func editWalletAddress() {
    showSaveIndicator = true
    Task { @MainActor in
      defer {
        showSaveIndicator = false
      }
      do {
        let walletAddress = try await accountRepository.updateWalletAddresses(
          walletId: wallet.id,
          walletAddress: wallet.address,
          nickname: walletNickname
        )
        accountDataManager.addOrEditWalletAddress(walletAddress)
        self.shouldDismiss = true
      } catch {
        guard let code = error.asErrorObject?.code else {
          toastData = .init(type: .error, title: error.userFriendlyMessage)
          return
        }
        switch code {
        case Constants.ErrorCode.duplicatedWalletNickname.value:
          toastData = .init(type: .error, title: L10N.Common.EnterNicknameOfWallet.NameExist.inlineError)
        default:
          toastData = .init(type: .error, title: error.userFriendlyMessage)
        }
      }
    }
  }
  
  func deleteWalletAddress(action: (() -> Void)?) {
    Task { @MainActor in
      isShowingDeleteConfirmationSheet = false
      
      defer { showDeleteIndicator = false }
      showDeleteIndicator = true
      do {
        let response = try await accountRepository.deleteWalletAddresses(
          walletAddress: wallet.address
        )
        if response.success {
          accountDataManager.removeWalletAddress(id: wallet.id)
          action?()
        }
      } catch {
        toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
}
