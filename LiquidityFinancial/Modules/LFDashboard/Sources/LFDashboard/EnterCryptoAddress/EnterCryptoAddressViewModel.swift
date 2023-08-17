import SwiftUI
import LFLocalizable
import LFUtilities
import Factory
import AccountDomain
import CodeScanner

@MainActor
final class EnterCryptoAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isPerformingAction = false
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastMessage: String?
  @Published var inputValue: String = ""
  @Published var isShowingScanner: Bool = false
  @Published var navigation: Navigation?
  
  let amount: Double
  let account: LFAccount
  
  init(account: LFAccount, amount: Double) {
    self.account = account
    self.amount = amount
  }
  
  var isActionAllowed: Bool {
    !inputValue.trimWhitespacesAndNewlines().isEmpty
  }
  
  func continueButtonTapped() {
    Haptic.impact(.light).generate()
    navigation = .confirm
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

extension EnterCryptoAddressViewModel {
  enum Navigation {
    case confirm
  }
}
