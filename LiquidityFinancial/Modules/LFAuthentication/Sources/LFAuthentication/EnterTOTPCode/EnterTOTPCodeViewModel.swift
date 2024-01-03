import AccountData
import AccountDomain
import Combine
import Foundation
import Factory
import LFStyleGuide
import LFUtilities
import LFLocalizable

@MainActor
final class EnterTOTPCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isTOTPCodeEntered: Bool = false
  @Published var isVerifying: Bool = false
  @Published var totpCode: String = .empty
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  let totpCodeLength = Constants.MaxCharacterLimit.mfaCode.value
  
  let purpose: EnterTOTPCodePurpose
  private var cancellable: Set<AnyCancellable> = []

  lazy var disableMFAUseCase: DisableMFAUseCaseProtocol = {
    DisableMFAUseCase(repository: accountRepository)
  }()
  
  init(purpose: EnterTOTPCodePurpose) {
    self.purpose = purpose
    observeTOTPInput()
  }
}

// MARK: - APIs
extension EnterTOTPCodeViewModel {
  private func disableMFAAuthentication() {
    Task {
      defer { isVerifying = false }
      isVerifying = true
      
      do {
        let response = try await disableMFAUseCase.execute(code: totpCode)
        if response.success {
          popup = .mfaTurnedOff
          accountDataManager.update(mfaEnabled: false)
        }
      } catch {
        handleError(error: error)
      }
    }
  }
  
  private func loginWithTOTPCode() {
    // TODO: - Will implemented in another ticket
  }
}

// MARK: - View Helpers
extension EnterTOTPCodeViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didUseRecoveryCodeLinkTap() {
    navigation = .recoveryCode
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func didContinueButtonTap() {
    switch purpose {
    case .disableMFA:
      disableMFAAuthentication()
    case .login:
      loginWithTOTPCode()
    }
  }
}

// MARK: - Private Functions
private extension EnterTOTPCodeViewModel {
  func observeTOTPInput() {
    $totpCode
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] code in
        guard let self else {
          return
        }
        guard code.count == self.totpCodeLength else {
          self.isTOTPCodeEntered = false
          self.errorMessage = nil
          return
        }
        self.isTOTPCodeEntered = true
      })
      .store(in: &cancellable)
  }
  
  func handleError(error: Error) {
    log.error(error.userFriendlyMessage)
    guard let errorObject = error.asErrorObject else {
      toastMessage = error.userFriendlyMessage
      return
    }
    switch errorObject.code {
    case Constants.ErrorCode.invalidTOTP.value:
      errorMessage = errorObject.message
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - Types
extension EnterTOTPCodeViewModel {
  enum Navigation {
    case recoveryCode
  }
  
  enum Popup {
    case mfaTurnedOff
  }
}

public enum EnterTOTPCodePurpose {
  case disableMFA
  case login
}
