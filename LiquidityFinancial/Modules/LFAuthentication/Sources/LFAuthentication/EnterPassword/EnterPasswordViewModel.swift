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
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  @Published var password: String = ""
  
  @Published var isDisableContinueButton: Bool = true
  
  lazy var loginWithPasswordUseCase: PasswordLoginUseCaseProtocol = {
    PasswordLoginUseCase(repository: accountRepository, dataManager: accountDataManager)
  }()
  
  init() {
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
      do {
        let _ = try await loginWithPasswordUseCase.execute(password: password)
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.localizedDescription)
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
  }
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
