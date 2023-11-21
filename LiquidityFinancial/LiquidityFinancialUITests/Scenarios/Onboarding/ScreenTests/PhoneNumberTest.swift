import XCTest

class PhoneNumberTest: BaseAppUITest {
  
  func test_uiElements_exists() {
    logoutIfNeeded()
    XCTAssertTrue(phoneNumberScreen.logoImage.waitForExistence(timeout: 3.0))
    XCTAssertTrue(phoneNumberScreen.phoneNumberLabel.waitForExistence(timeout: 3.0))
    XCTAssertTrue(phoneNumberScreen.phoneNumberTextField.waitForExistence(timeout: 3.0))
    XCTAssertTrue(phoneNumberScreen.continueButton.waitForExistence(timeout: 3.0))
    XCTAssertFalse(phoneNumberScreen.continueButton.isEnabled)
  }
  
  func test_input_normalPhoneNumber() {
    logoutIfNeeded()
    XCTAssertFalse(phoneNumberScreen.continueButton.isEnabled)
    phoneNumberScreen
      .typePhoneNumber(TestConfiguration.UserAccount.validAccount.informations.phoneNumber)
      .tapContinueButton()
    XCTAssertTrue(verificationCodeScreen.headerTitle.waitForExistence(timeout: 2.0))
  }
  
  func test_input_lockedPhoneNumber() {
    logoutIfNeeded()
    XCTAssertFalse(phoneNumberScreen.continueButton.isEnabled)
    phoneNumberScreen
      .typePhoneNumber(TestConfiguration.UserAccount.lockedAccount.informations.phoneNumber)
      .tapContinueButton()
    XCTAssertTrue(accountLockedScreen.contactSupportTitle.waitForExistence(timeout: 3.0))
  }
  
  func test_tap_voipTerm() {
  }
  
  func test_tap_conditionLink() {
  }
}
