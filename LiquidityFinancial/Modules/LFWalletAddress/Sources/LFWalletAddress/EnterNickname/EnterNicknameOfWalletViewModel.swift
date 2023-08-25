import Foundation
import LFLocalizable
import Factory
import AccountData
import AccountDomain
import SwiftUI

@MainActor
class EnterNicknameOfWalletViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @Published var shouldDismiss: Bool = false
  
  @Published var walletNickname: String = .empty
  @Published var showIndicator: Bool = false
  @Published var numberOfShakes: Int = 0
  @Published var inlineMessage: String?
  @Published var toastMessage: String?

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

extension EnterNicknameOfWalletViewModel {
  func saveWalletAddress() {
    numberOfShakes = 0
    showIndicator = true
    Task { @MainActor in
      defer {
        showIndicator = false
      }
      do {
        let walletAddress = try await accountRepository.createWalletAddresses(
          accountId: accountId,
          address: walletAddress,
          nickname: walletNickname
        )
        accountDataManager.addOrEditWalletAddress(walletAddress)
        toastMessage = LFLocalizable.EnterNicknameOfWallet.walletWasSaved
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.shouldDismiss = true
        }
      } catch {
        self.handleAPIError(error)
      }
    }
  }

  func onEditingWalletName() {
    if inlineMessage.isNotNil {
      inlineMessage = nil
    }
  }
}

// MARK: - Private Functions

private extension EnterNicknameOfWalletViewModel {
  func handleAPIError(_ error: Error) {
    // TODO: Need to check duplicate wallet address later
    guard error.asErrorObject != nil else {
      toastMessage = error.localizedDescription
      return
    }
    inlineMessage = LFLocalizable.EnterNicknameOfWallet.NameExist.inlineError
  }
}
