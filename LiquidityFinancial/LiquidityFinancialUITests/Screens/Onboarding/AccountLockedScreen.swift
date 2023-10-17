import XCTest
import LFAccessibility

class AccountLockedScreen: BaseScreen {
  lazy var lockedImage = app.images[LFAccessibility.AccountLockedScreen.lockedImage]
  lazy var contactSupportTitle = app.staticTexts[LFAccessibility.AccountLockedScreen.contactSupportTitle]
  lazy var contactSupportDescription = app.staticTexts[LFAccessibility.AccountLockedScreen.contactSupportDescription]
  lazy var contactSupportButton = app.buttons[LFAccessibility.AccountLockedScreen.contactSupportButton]
  lazy var logoutButton = app.buttons[LFAccessibility.AccountLockedScreen.logoutButton]
  
  func tapContactSupportButton() {
    XCTAssert(self.contactSupportButton.waitForExistence(timeout: 1.0))
    self.contactSupportButton.tap()
  }
  
  func tapLogoutButton() {
    XCTAssert(self.logoutButton.waitForExistence(timeout: 1.0))
    self.logoutButton.tap()
  }
}
