import XCTest

final class LoginFlowTest: BaseAppUITest {
  func test_login_normalAccount() {
    if !phoneNumberScreen.phoneNumberTextField.waitForExistence(timeout: 3.0) {
      logoutIfNeeded()
    }
    let account = TestConfiguration.UserAccount.validAccount.informations
    phoneNumberScreen
      .typePhoneNumber(account.phoneNumber)
      .tapContinueButton()
    
    // TODO: - We will implemented later after we have production env
    //    verificationCodeScreen
    //      .typeVerificationCode("34423")
    
    if identityVerificationCodeScreen.headerTitle.waitForExistence(timeout: 4.0) {
      identityVerificationCodeScreen
        .typeLast4DigitsOfSSN(account.ssn)
        .tapContinueButton()
    }
    
    XCTAssert(homeScreen.homeTabView.waitForExistence(timeout: 20.0))
  }
}
