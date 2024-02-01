import XCTest

class PhoneNumberTest: BaseAppUITest {
  func test_input_normalPhoneNumber() {
    logoutIfNeeded()
    XCTAssertFalse(phoneNumberScreen.continueButton.isEnabled)
    phoneNumberScreen
      .typePhoneNumber(TestConfiguration.UserAccount.validAccount.informations.phoneNumber)
      .tapContinueButton()
    // TODO: - We will update later
    // XCTAssertTrue(verificationCodeScreen.headerTitle.waitForExistence(timeout: 2.0))
  }
  
  func test_input_lockedPhoneNumber() {
    logoutIfNeeded()
    XCTAssertFalse(phoneNumberScreen.continueButton.isEnabled)
    phoneNumberScreen
      .typePhoneNumber(TestConfiguration.UserAccount.lockedAccount.informations.phoneNumber)
      .tapContinueButton()
  }
}
