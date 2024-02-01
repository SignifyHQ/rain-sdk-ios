import XCTest
import LFAccessibility

class PhoneNumberScreen: BaseScreen {
  lazy var logoImage = app.images[LFAccessibility.PhoneNumber.logoImage]
  lazy var phoneNumberLabel = app.staticTexts[LFAccessibility.PhoneNumber.headerTitle]
  lazy var phoneNumberTextField = app.textFields[LFAccessibility.PhoneNumber.textField]
  lazy var voipTermTextTappable = app.otherElements[LFAccessibility.PhoneNumber.voipTermTextTappable]
  lazy var conditionTextTappable = app.otherElements[LFAccessibility.PhoneNumber.conditionTextTappable]
  lazy var continueButton = app.buttons[LFAccessibility.PhoneNumber.continueButton]
  
  func typePhoneNumber(_ phoneNumber: String) -> PhoneNumberScreen {
    // TODO: - We will update later
    self
  }
  
  func tapContinueButton() {
    XCTAssert(self.continueButton.waitForExistence(timeout: 3))
    self.continueButton.tap()
  }
}
