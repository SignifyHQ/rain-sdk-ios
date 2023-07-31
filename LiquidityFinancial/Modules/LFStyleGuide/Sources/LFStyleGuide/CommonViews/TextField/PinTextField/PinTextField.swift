import SwiftUI
import LFUtilities

public struct PinTextField: UIViewRepresentable {
  @ObservedObject var viewItem: PinTextFieldViewItem
  let isShown: Bool
  var onTextChange: (String) -> Void
  var onBackPressed: (PinTextFieldViewItem) -> Void
  
  public init(
    viewItem: PinTextFieldViewItem,
    isShown: Bool,
    onTextChange: @escaping (String) -> Void,
    onBackPressed: @escaping (PinTextFieldViewItem) -> Void
  ) {
    self.viewItem = viewItem
    self.isShown = isShown
    self.onTextChange = onTextChange
    self.onBackPressed = onBackPressed
  }
  
  public func makeUIView(context: UIViewRepresentableContext<PinTextField>) -> BackPressTextField {
    let textField = BackPressTextField(frame: .zero)
    textField.isSecureTextEntry = false
    textField.keyboardType = .numberPad
    textField.font = Fonts.bold.font(size: 32)
    textField.delegate = context.coordinator
    textField.autocorrectionType = .no
    textField.textAlignment = .center
    textField.placeholder = viewItem.placeHolderText
    textField.text = viewItem.text
    textField.borderStyle = .none
    textField.backDelegate = context.coordinator
    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textField.textColor = Colors.label.color
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    return textField
  }
  
  public func updateUIView(_ uiView: BackPressTextField, context _: Context) {
    updateResponder(textField: uiView)
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  private let helper = Helper()
  
  private func updateResponder(textField: BackPressTextField) {
    textField.tag = viewItem.tag
    textField.text = viewItem.text
    if viewItem.isInFocus, isShown {
      textField.becomeFirstResponder()
    }
  }
}

extension PinTextField {
  public final class Coordinator: NSObject, UITextFieldDelegate, BackPressTextFieldDelegate {
    private let parent: PinTextField
    
    public init(_ textField: PinTextField) {
      parent = textField
    }
    
    public func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
      parent.onTextChange(string)
      return false
    }
    
    public func backPressed(textfield _: BackPressTextField) {
      parent.onBackPressed(parent.viewItem)
    }
  }
}

extension PinTextField {
  class Helper {
    var onDoneButtonTapped: (() -> Void)?
    
    @objc
    func doneButtonTapped() {
      onDoneButtonTapped?()
    }
  }
}
