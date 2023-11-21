import XCTest

class VerificationCodeTest: BaseAppUITest {

  func test_uiElements_exists() {
    logoutIfNeeded()
    phoneNumberScreen
      .typePhoneNumber(TestConfiguration.UserAccount.validAccount.informations.phoneNumber)
      .tapContinueButton()
    XCTAssertTrue(verificationCodeScreen.headerTitle.waitForExistence(timeout: 3.0))
    XCTAssertTrue(verificationCodeScreen.headerDescription.waitForExistence(timeout: 3.0))
    XCTAssertTrue(verificationCodeScreen.verificationCodeTextField.waitForExistence(timeout: 3.0))
  }
  
  // TODO: - Will be implemented after we have production env
  func test_input_correctOTP() {}
  
  // TODO: - Will be implemented after we have production env
  func test_input_wrongOTP() {}
  
  // TODO: - Will be implemented after we have production env
  func test_resend_otp() {}
}
