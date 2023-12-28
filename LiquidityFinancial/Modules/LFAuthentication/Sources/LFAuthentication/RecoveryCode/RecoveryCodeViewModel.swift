import AccountData
import AccountDomain
import Combine
import Foundation
import Factory
import LFStyleGuide
import LFUtilities
import LFLocalizable

@MainActor
final class RecoveryCodeViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isVerifying: Bool = false
  @Published var recoveryCode: String = .empty
  @Published var inlineErrorMessage: String?
  @Published var toastMessage: String?
  @Published var popup: Popup?

  init() {
  }
}

// MARK: - View Helpers
extension RecoveryCodeViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didContinueButtonTap() {
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Types
extension RecoveryCodeViewModel {
  enum Popup {
    case mfaRecovered
  }
}
