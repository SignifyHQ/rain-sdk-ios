import AccountData
import AccountDomain
import Foundation
import LFUtilities
import LFLocalizable
import LFStyleGuide
import Factory
import Services

@MainActor
public final class EnterPasswordViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var navigation: Navigation?
  @Published var shouldDismissFlow: Bool?
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var isInlineErrorShown: Bool = false
  
  @Published var password: String = ""
  
  @Published var isDisableContinueButton: Bool = true
  
  var purpose: EnterPasswordPurpose
  
  lazy var loginWithPasswordUseCase: PasswordLoginUseCaseProtocol = {
    PasswordLoginUseCase(repository: accountRepository, dataManager: accountDataManager)
  }()
  
  init(
    purpose: EnterPasswordPurpose
  ) {
    self.purpose = purpose
    observePasswordInput()
  }
}

// MARK: - View Helpers
extension EnterPasswordViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didTapContinueButton() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      isInlineErrorShown = false
      
      do {
        let _ = try await loginWithPasswordUseCase.execute(password: password)
        
        switch purpose {
        case .biometricsFallback:
          shouldDismissFlow = true
        case .changePassword:
          navigation = .changePassword
        }
      } catch {
        if error.inlineError == .invalidCredentials {
          isInlineErrorShown = true
        } else {
          toastMessage = error.userFriendlyMessage
        }
        
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func didTapForgotPasswordButton() {
    navigation = .recoverPassword
  }
}

// MARK: - Enums

extension EnterPasswordViewModel {
  enum Navigation {
    case recoverPassword
    case changePassword
  }
}

public enum EnterPasswordPurpose {
  case biometricsFallback
  case changePassword
}

// MARK: - Private Functions
private extension EnterPasswordViewModel {
  private func observePasswordInput() {
    $password
      .map { passwordString in
        passwordString.trimWhitespacesAndNewlines().isEmpty
      }
      .assign(to: &$isDisableContinueButton)
  }
}
