import XCTest

class IdentityVerificationCodeTest: BaseAppUITest {
  
  func test_uiElements_exists() {
    if !phoneNumberScreen.phoneNumberTextField.waitForExistence(timeout: 3.0) {
      logoutIfNeeded()
    }
    let account = TestConfiguration.UserAccount.validAccount.informations
    phoneNumberScreen
      .typePhoneNumber(account.phoneNumber)
      .tapContinueButton()
    XCTAssertTrue(identityVerificationCodeScreen.headerTitle.waitForExistence(timeout: 5.0))
    XCTAssertTrue(identityVerificationCodeScreen.ssnSecureField.waitForExistence(timeout: 5.0))
    XCTAssertTrue(identityVerificationCodeScreen.continueButton.waitForExistence(timeout: 5.0))
    XCTAssertFalse(identityVerificationCodeScreen.continueButton.isEnabled)
  }
  
  func test_input_correctSSN() {
    if !phoneNumberScreen.phoneNumberTextField.waitForExistence(timeout: 3.0) {
      logoutIfNeeded()
    }
    let validAccount = TestConfiguration.UserAccount.validAccount.informations
    phoneNumberScreen
      .typePhoneNumber(validAccount.phoneNumber)
      .tapContinueButton()
    XCTAssertFalse(identityVerificationCodeScreen.continueButton.isEnabled)
    identityVerificationCodeScreen
      .typeLast4DigitsOfSSN(validAccount.ssn)
      .tapContinueButton()
    XCTAssert(homeScreen.homeTabView.waitForExistence(timeout: 10.0))
  }
  
  func test_input_invalidSSN() {
    if !phoneNumberScreen.phoneNumberTextField.waitForExistence(timeout: 3.0) {
      logoutIfNeeded()
    }
    let validAccount = TestConfiguration.UserAccount.validAccount.informations
    let invalidSSN = "0000"
    phoneNumberScreen
      .typePhoneNumber(validAccount.phoneNumber)
      .tapContinueButton()
    
    phoneNumberScreen
      .typePhoneNumber(validAccount.phoneNumber)
      .tapContinueButton()
    XCTAssertFalse(phoneNumberScreen.continueButton.isEnabled)
    identityVerificationCodeScreen
      .typeLast4DigitsOfSSN(invalidSSN)
      .tapContinueButton()
  }
}
