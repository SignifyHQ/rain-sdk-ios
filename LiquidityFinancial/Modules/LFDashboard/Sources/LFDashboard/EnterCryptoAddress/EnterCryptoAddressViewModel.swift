import SwiftUI
import LFLocalizable
import LFUtilities
import Factory
import AccountDomain
import CodeScanner

@MainActor
final class EnterCryptoAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var account: LFAccount
  @Published var isActionAllowed = false
  @Published var isPerformingAction = false
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastMessage: String?
  @Published var inputValue: String = ""
  @Published var isShowingScanner: Bool = false
  
  init(account: LFAccount) {
    self.account = account
  }
  
  func continueButtonTapped() {
    Haptic.impact(.light).generate()
  }
  
  func scanAddressTap() {
    isShowingScanner = true
  }
  
  func clearValue() {
    inputValue = "".trimWhitespacesAndNewlines()
  }
  
  func handleScan(result: Result<ScanResult, ScanError>) {
    isShowingScanner = false
    switch result {
    case let .success(result):
      inputValue = result.string
    case let .failure(error):
      log.error("Scanning failed: \(error.localizedDescription)")
    }
  }
}
