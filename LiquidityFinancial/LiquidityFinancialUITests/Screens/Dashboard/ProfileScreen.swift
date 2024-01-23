import XCTest
import LFLocalizable
import LFAccessibility

class ProfileScreen: BaseScreen {
  lazy var logoutButton = app.buttons[LFAccessibility.ProfileScreen.logoutButton]
  lazy var popupTitle = app.staticTexts[LFAccessibility.Popup.title]
  lazy var popupPrimaryButton = app.buttons[LFAccessibility.Popup.primaryButton]
  lazy var popupSecondaryButton = app.buttons[LFAccessibility.Popup.secondaryButton]

  func tapLogoutButton() {
    self.logoutButton.tap()
    XCTAssert(popupTitle.waitForExistence(timeout: 3.0))
    if popupTitle.label.elementsEqual(L10N.Common.Profile.Logout.message.uppercased()) {
      popupPrimaryButton.tap()
    }
  }
}
