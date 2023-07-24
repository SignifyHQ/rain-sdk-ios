import UIKit

protocol BackPressTextFieldDelegate: AnyObject {
  func backPressed(textfield: BackPressTextField)
}

public final class BackPressTextField: UITextField {
  weak var backDelegate: BackPressTextFieldDelegate?
  
  public override func deleteBackward() {
    super.deleteBackward()
    backDelegate?.backPressed(textfield: self)
  }
}
