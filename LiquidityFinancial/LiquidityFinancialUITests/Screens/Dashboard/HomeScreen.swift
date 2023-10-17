import XCTest
import LFAccessibility

class HomeScreen: BaseScreen {
  lazy var homeTabView = app.tabBars[LFAccessibility.HomeScreen.tabView]
  lazy var profileButton = app.buttons[LFAccessibility.HomeScreen.profileButton]

  func tapProfileIconButton() {
    self.profileButton.tap()
  }
}
