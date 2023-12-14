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
  @Published public var shouldDismiss: Bool = false
  
  @Published var passwordString: String = ""
  
  @Published var isLengthCorrect: Bool = false
  @Published var containsSpecialCharacters: Bool = false
  @Published var containsLowerAndUpperCase: Bool = false
  
  @Published var isDontMatchErrorShown: Bool = false
  @Published var isContinueEnabled: Bool = false
  
  lazy var createPasswordUseCase: CreatePasswordUseCaseProtocol = {
    CreatePasswordUseCase(repository: accountRepository)
  }()
  
  lazy var getUserUseCase: GetUserUseCaseProtocol = {
    GetUserUseCase(repository: accountRepository)
  }()

  let onActionContinue: (_ viewModel: CreatePasswordViewModel) -> Void
  
  init(onActionContinue: @escaping (_ viewModel: CreatePasswordViewModel) -> Void) {
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
        try await createPasswordUseCase.execute(password: passwordString)
        let user = try await getUserUseCase.execute()
        accountDataManager.update(missingSteps: user.missingSteps)
        onActionContinue(self)
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
}
