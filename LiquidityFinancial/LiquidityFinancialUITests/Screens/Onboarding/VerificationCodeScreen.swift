import XCTest
import LFAccessibility

class VerificationCodeScreen: BaseScreen {
  lazy var headerTitle = app.staticTexts[LFAccessibility.VerificationCode.headerTitle]
  lazy var headerDescription = app.staticTexts[LFAccessibility.VerificationCode.headerDescription]
  lazy var resendTimer = app.staticTexts[LFAccessibility.VerificationCode.resendTimerText]
  lazy var verificationCodeTextField = app.textFields[LFAccessibility.VerificationCode.verificationCodeTextField]
  lazy var resendCodeButton = app.buttons[LFAccessibility.VerificationCode.resendButton]
  
  func typeVerificationCode(_ code: String) {
    XCTAssert(self.verificationCodeTextField.waitForExistence(timeout: 3))
    self.verificationCodeTextField.typeText(code)
  }
  
  func tapResendButton() {
    XCTAssert(self.resendCodeButton.waitForExistence(timeout: 3))
    self.resendCodeButton.tap()
  }
}
