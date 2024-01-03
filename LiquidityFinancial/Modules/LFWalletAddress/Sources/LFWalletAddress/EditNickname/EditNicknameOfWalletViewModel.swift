import Foundation
import LFLocalizable
import Factory
import AccountData
import AccountDomain
import SwiftUI
import LFUtilities

@MainActor
class EditNicknameOfWalletViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var shouldDismiss: Bool = false
  
  @Published var walletNickname: String = .empty
  @Published var showIndicator: Bool = false
  @Published var numberOfShakes: Int = 0
  @Published var inlineMessage: String?
  @Published var toastMessage: String?

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

extension EditNicknameOfWalletViewModel {
  func editWalletAddress() {
    numberOfShakes = 0
    showIndicator = true
    Task { @MainActor in
      defer {
        showIndicator = false
      }
      do {
        let walletAddress = try await accountRepository.updateWalletAddresses(
          accountId: accountId,
          walletId: wallet.id,
          walletAddress: wallet.address,
          nickname: walletNickname
        )
        accountDataManager.addOrEditWalletAddress(walletAddress)
        toastMessage = LFLocalizable.EnterNicknameOfWallet.walletWasSaved
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.shouldDismiss = true
        }
      } catch {
        guard let code = error.asErrorObject?.code else {
          toastMessage = error.userFriendlyMessage
          return
        }
        switch code {
        case Constants.ErrorCode.duplicatedWalletNickname.value:
          inlineMessage = LFLocalizable.EnterNicknameOfWallet.NameExist.inlineError
        default:
          toastMessage = error.userFriendlyMessage
        }
      }
    }
  }

  func onEditingWalletName() {
    if inlineMessage.isNotNil {
      inlineMessage = nil
    }
  }
}
