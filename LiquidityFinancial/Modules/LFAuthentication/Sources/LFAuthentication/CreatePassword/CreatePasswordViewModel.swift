import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services

public final class CreatePasswordViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  @Published var passwordString: String = ""
  @Published var confirmPasswordString: String = ""
  
  @Published var doPasswordsMatch: Bool = false
  @Published var isLengthCorrect: Bool = false
  @Published var containsSpecialCharacters: Bool = false
  @Published var containsLowerAndUpperCase: Bool = false
  
  @Published var isDontMatchErrorShown: Bool = false
  @Published var isContinueEnabled: Bool = false
  
  init() {
    observePasswordInput()
    observePasswordValidation()
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func observePasswordInput() {
    Publishers
      .CombineLatest($passwordString, $confirmPasswordString)
      .map { passwordString, confirmPasswordString in
        passwordString == confirmPasswordString
      }
      .assign(to: &$doPasswordsMatch)
    
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
      .CombineLatest3($passwordString, $confirmPasswordString, $doPasswordsMatch)
      .map { passwordString, confirmPasswordString, doPasswordsMatch in
        guard !passwordString.isEmpty,
              !confirmPasswordString.isEmpty
        else {
          return false
        }
        
        return !doPasswordsMatch
      }
      .assign(to: &$isDontMatchErrorShown)
    
    Publishers
      .CombineLatest4($doPasswordsMatch, $isLengthCorrect, $containsSpecialCharacters, $containsLowerAndUpperCase)
      .map { doPasswordsMatch, isLengthCorrect, containsSpecialCharacters, containsLowerAndUpperCase in
        doPasswordsMatch && isLengthCorrect && containsSpecialCharacters && containsLowerAndUpperCase
      }
      .assign(to: &$isContinueEnabled)
  }
  
  func actionContinue() {
    
  }
}
