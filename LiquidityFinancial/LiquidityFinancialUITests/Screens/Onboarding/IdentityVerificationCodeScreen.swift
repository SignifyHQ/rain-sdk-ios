import XCTest
import LFAccessibility

class IdentityVerificationCodeScreen: BaseScreen {
  lazy var headerTitle = app.staticTexts[LFAccessibility.IdentityVerificationCode.headerTitle]
  lazy var ssnSecureField = app.secureTextFields[LFAccessibility.IdentityVerificationCode.ssnSecureField]
  lazy var continueButton = app.buttons[LFAccessibility.IdentityVerificationCode.continueButton]
  
  func typeLast4DigitsOfSSN(_ code: String) -> IdentityVerificationCodeScreen {
    // TODO: - We will update later
    self
  }
  
  func tapContinueButton() {
    self.continueButton.tap()
  }
}
