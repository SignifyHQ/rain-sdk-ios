import UIKit

protocol BackPressTextFieldDelegate: AnyObject {
  func backPressed(textfield: BackPressTextField)
}

final class BackPressTextField: UITextField {
  weak var backDelegate: BackPressTextFieldDelegate?
  
  override func deleteBackward() {
    super.deleteBackward()
    backDelegate?.backPressed(textfield: self)
  }
}
