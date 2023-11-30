import Foundation
import LFUtilities
import LFLocalizable
import LFStyleGuide
import Factory
import Services

public final class EnterPasswordViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isVerifyingPassword: Bool = false
  @Published var isDisableContinueButton: Bool = true
  @Published var toastMessage: String?
  
  @Published var password: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
}

// MARK: - View Helpers
extension EnterPasswordViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didTapContinueButton() {
  }
  
  func didTapForgotPasswordButton() {
  }
}

// MARK: - Private Functions
private extension EnterPasswordViewModel {
  func isAllDataFilled() {
    isDisableContinueButton = password.trimWhitespacesAndNewlines().isEmpty
  }
}
