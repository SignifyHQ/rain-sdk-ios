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
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var recoveryCode: String = .empty
  
  @Published var isVerifying: Bool = false
  @Published var inlineErrorMessage: String?
  @Published var toastMessage: String?
  @Published var popup: Popup?

  var onActionContinue: () -> Void
  
  init(
    onActionContinue: @escaping () -> Void
  ) {
    self.onActionContinue = onActionContinue
  }
  
  lazy var disableMFAUseCase: DisableMFAUseCaseProtocol = {
    DisableMFAUseCase(repository: accountRepository)
  }()
}

// MARK: - View Helpers
extension RecoveryCodeViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didContinueButtonTap() {
    disableMFAAuthentication()
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - APIs

extension RecoveryCodeViewModel {
  private func disableMFAAuthentication() {
    Task {
      defer { isVerifying = false }
      isVerifying = true
      inlineErrorMessage = nil
      
      do {
        let response = try await disableMFAUseCase.execute(code: recoveryCode.trimWhitespacesAndNewlines())
        if response.success {
          popup = .mfaTurnedOff
          accountDataManager.update(mfaEnabled: false)
        }
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - Private Functions

extension RecoveryCodeViewModel {
  func handleError(error: Error) {
    log.error(error.localizedDescription)
    
    guard let errorObject = error.asErrorObject
    else {
      toastMessage = error.localizedDescription
      return
    }
    
    switch errorObject.code {
    case Constants.ErrorCode.invalidTOTP.value:
      inlineErrorMessage = errorObject.message
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - Types
extension RecoveryCodeViewModel {
  enum Popup {
    case mfaTurnedOff
  }
}
