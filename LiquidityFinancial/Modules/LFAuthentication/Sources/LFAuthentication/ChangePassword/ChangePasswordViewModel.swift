import AccountData
import AccountDomain
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services

@MainActor
public final class ChangePasswordViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var shouldDismiss: Bool = false
  
  @Published var oldPasswordString: String = ""
  @Published var newPasswordString: String = ""
  
  @Published var isLengthCorrect: Bool = false
  @Published var containsSpecialCharacters: Bool = false
  @Published var containsLowerAndUpperCase: Bool = false
  
  @Published var isContinueEnabled: Bool = false
  
  lazy var changePasswordUseCase: ChangePasswordUseCaseProtocol = {
    ChangePasswordUseCase(repository: accountRepository)
  }()

  init() {
    observePasswordInput()
    observePasswordValidation()
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func createPassword() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      do {
        try await changePasswordUseCase.execute(oldPassword: oldPasswordString, newPassword: newPasswordString)
        shouldDismiss = true
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.localizedDescription)
      }
    }
  }
  
  func observePasswordInput() {
    $newPasswordString
      .map { password in
        password.count >= 8
      }
      .assign(to: &$isLengthCorrect)
    
    $newPasswordString
      .map { password in
        password.isValid(for: .containsSpecialCharacter)
      }
      .assign(to: &$containsSpecialCharacters)
    
    $newPasswordString
      .map { password in
        password.isValid(for: .containsLowerCase) && password.isValid(for: .containsUpperCase)
      }
      .assign(to: &$containsLowerAndUpperCase)
  }
  
  func observePasswordValidation() {
    Publishers
      .CombineLatest4($isLengthCorrect, $containsSpecialCharacters, $containsLowerAndUpperCase, $oldPasswordString)
      .map { isLengthCorrect, containsSpecialCharacters, containsLowerAndUpperCase, oldPassword in
        isLengthCorrect && containsSpecialCharacters && containsLowerAndUpperCase && !oldPassword.isEmpty
      }
      .assign(to: &$isContinueEnabled)
  }
  
  func didTapContinueButton() {
    createPassword()
  }
}
