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
public final class CreatePasswordViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var shouldShowConfirmationPopup: Bool = false
  
  @Published var passwordString: String = ""
  
  @Published var isLengthCorrect: Bool = false
  @Published var containsSpecialCharacters: Bool = false
  @Published var containsLowerAndUpperCase: Bool = false
  
  @Published var isDontMatchErrorShown: Bool = false
  @Published var isContinueEnabled: Bool = false
  
  var purpose: CreatePasswordPurpose
  
  lazy var createPasswordUseCase: CreatePasswordUseCaseProtocol = {
    CreatePasswordUseCase(repository: accountRepository)
  }()
  
  lazy var resetPasswordUserCase: ResetPasswordUseCaseProtocol = {
    ResetPasswordUseCase(repository: accountRepository, dataManager: accountDataManager)
  }()
  
  lazy var getUserUseCase: GetUserUseCaseProtocol = {
    GetUserUseCase(repository: accountRepository)
  }()

  let onActionContinue: () -> Void
  
  init(
    purpose: CreatePasswordPurpose,
    onActionContinue: @escaping () -> Void
  ) {
    self.purpose = purpose
    self.onActionContinue = onActionContinue
    
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
        switch purpose {
        case .createNewUser, .createExistingUser, .changePassword:
          try await createPasswordUseCase.execute(password: passwordString)
          let user = try await getUserUseCase.execute()
          accountDataManager.update(missingSteps: user.missingSteps)
        case .resetPassword(let token):
          try await resetPasswordUserCase.execute(password: passwordString, token: token)
        }
        
        // In onboarding should continue flow on success
        if case .createNewUser = purpose {
          onActionContinue()
        }
        // In all other cases should show a confirmation popup first
        else {
          shouldShowConfirmationPopup = true
        }
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.localizedDescription)
      }
    }
  }
  
  func observePasswordInput() {
    $passwordString
      .map { password in
        password.count >= 8
      }
      .assign(to: &$isLengthCorrect)
    
    $passwordString
      .map { password in
        password.isValid(for: .containsSpecialCharacter)
      }
      .assign(to: &$containsSpecialCharacters)
    
    $passwordString
      .map { password in
        password.isValid(for: .containsLowerCase) && password.isValid(for: .containsUpperCase)
      }
      .assign(to: &$containsLowerAndUpperCase)
  }
  
  func observePasswordValidation() {
    Publishers
      .CombineLatest3($isLengthCorrect, $containsSpecialCharacters, $containsLowerAndUpperCase)
      .map { isLengthCorrect, containsSpecialCharacters, containsLowerAndUpperCase in
        isLengthCorrect && containsSpecialCharacters && containsLowerAndUpperCase
      }
      .assign(to: &$isContinueEnabled)
  }
  
  func actionContinue() {
    createPassword()
  }
  
  func successMessage() -> String {
    switch purpose {
    case .createExistingUser:
      return LFLocalizable.Authentication.CreatePassword.SuccessPopup.title
    case .changePassword:
      return LFLocalizable.Authentication.ChangePassword.SuccessPopup.title
    case .resetPassword:
      return LFLocalizable.Authentication.ResetPassword.SuccessPopup.title
    case .createNewUser:
      return ""
    }
  }
}

public enum CreatePasswordPurpose {
  case createNewUser
  case createExistingUser
  case resetPassword(token: String)
  case changePassword
  
  var screenTitle: String {
    switch self {
    case .changePassword:
      return LFLocalizable.Authentication.ChangePassword.title
    default:
      return LFLocalizable.Authentication.CreatePassword.title.uppercased()
    }
  }
}
