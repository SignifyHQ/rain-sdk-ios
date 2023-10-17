import XCTest

class BaseAppUITest: XCTestCase {

  let app = XCUIApplication()
  
  // Onboarding
  var phoneNumberScreen = PhoneNumberScreen()
  var verificationCodeScreen = VerificationCodeScreen()
  var identityVerificationCodeScreen = IdentityVerificationCodeScreen()
  var accountLockedScreen = AccountLockedScreen()
  
  // Dashboard
  var homeScreen = HomeScreen()
  var profileScreen = ProfileScreen()
  
  override class func setUp() {
  }
  
  override func setUp() {
    continueAfterFailure = false
    self.app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
}

// MARK: - Functions
extension BaseAppUITest {
  func logoutIfNeeded() {
    if homeScreen.profileButton.waitForExistence(timeout: 10.0) {
      homeScreen.tapProfileIconButton()
      profileScreen.tapLogoutButton()
    }
  }
  
  func loginIfNeeded() {
    if let phoneNumber = phoneNumberScreen.phoneNumberTextField.value as? String, phoneNumber.isEmpty {
      let account = TestConfiguration.UserAccount.validAccount.informations
      phoneNumberScreen
        .typePhoneNumber(account.phoneNumber)
        .tapContinueButton()
      
      // TODO: - We will implemented later after we have production env
      //    verificationCodeScreen
      //      .typeVerificationCode("34423")
      
      if identityVerificationCodeScreen.headerTitle.waitForExistence(timeout: 2.0) {
        identityVerificationCodeScreen
          .typeLast4DigitsOfSSN(account.ssn)
          .tapContinueButton()
      }
    }
  }
}
