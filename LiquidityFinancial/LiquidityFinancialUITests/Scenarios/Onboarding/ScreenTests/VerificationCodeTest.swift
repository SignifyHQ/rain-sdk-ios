import XCTest

class VerificationCodeTest: BaseAppUITest {

  func test_uiElements_exists() {
    logoutIfNeeded()
    phoneNumberScreen
      .typePhoneNumber(TestConfiguration.UserAccount.validAccount.informations.phoneNumber)
      .tapContinueButton()
    // TODO: - We will update UI Test later
    //    XCTAssertTrue(verificationCodeScreen.headerTitle.waitForExistence(timeout: 3.0))
    //    XCTAssertTrue(verificationCodeScreen.headerDescription.waitForExistence(timeout: 3.0))
    //    XCTAssertTrue(verificationCodeScreen.verificationCodeTextField.waitForExistence(timeout: 3.0))
  }
}
