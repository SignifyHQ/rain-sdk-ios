import SwiftUI
import LFUtilities

public struct PinCodeView: View {
  @State private var codeViewItems: [PinTextFieldViewItem] = .init()
  
  @Binding private var code: String
  @Binding private var isDisabled: Bool

  private let codeLength: Int
  private let isSecureInput: Bool
  private let pinCodeConfig: PinCodeConfig

  public init(
    code: Binding<String>,
    isDisabled: Binding<Bool> = .constant(false),
    codeLength: Int,
    isSecureInput: Bool = false,
    pinCodeConfig: PinCodeView.PinCodeConfig = .default
  ) {
    _code = code
    _isDisabled = isDisabled
    self.codeLength = codeLength
    self.isSecureInput = isSecureInput
    self.pinCodeConfig = pinCodeConfig
  }
  
  public var body: some View {
    HStack(spacing: 10) {
      ForEach(codeViewItems) { item in
        PinTextField(
          viewItem: item,
          isShown: true,
          isSecureInput: isSecureInput,
          onTextChange: { value in
            didTextFieldTextChange(replacementText: value, viewItem: item)
          },
          onBackPressed: { item in
            onTextFieldBackPressed(viewItem: item)
          }
        )
        .background(
          item.text.isEmpty ? pinCodeConfig.background : pinCodeConfig.filledBackground
        )
        .cornerRadius(pinCodeConfig.radius)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: pinCodeConfig.height)
        .disabled(isDisabled)
      }
    }
    .onAppear {
      createTextFields()
    }
  }
}

// MARK: - Types
public extension PinCodeView {
  struct PinCodeConfig {
    let height: CGFloat
    let radius: CGFloat
    let background: Color
    let filledBackground: Color
    
    init(height: CGFloat, radius: CGFloat, background: Color, filledBackground: Color) {
      self.height = height
      self.radius = radius
      self.background = background
      self.filledBackground = filledBackground
    }
    
    public static var `default` = PinCodeConfig(
      height: 70,
      radius: 10,
      background: Colors.buttons.swiftUIColor,
      filledBackground: Colors.secondaryBackground.swiftUIColor
    )
  }
}

// MARK: - View Helpers
extension PinCodeView {
  func createTextFields() {
    codeViewItems = (0 ..< codeLength).map { index in
      PinTextFieldViewItem(
        text: .empty,
        placeHolderText: .empty,
        isInFocus: false,
        tag: index
      )
    }
    setFocusToTextField(withTag: 0)
  }
  
  func didTextFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem) {
    guard replacementText.isStringValidNumber() else {
      return
    }
    
    guard replacementText.count <= 1 else {
      updateTextFieldsForMultipleCharacters(replacementText)
      sendCode()
      return
    }
    
    // Handling user deletion at any position without triggering deleteBackward action
    if replacementText.isEmpty, !viewItem.text.isEmpty {
      handleEmptyText(viewItem)
    } else {
      handleNonEmptyText(replacementText, viewItem)
    }
    
    viewItem.text = replacementText
    sendCode()
  }
  
  func handleEmptyText(_ viewItem: PinTextFieldViewItem) {
    guard let previousViewItem = previousViewItemFrom(tag: viewItem.tag) else {
      setFocusToTextField(withTag: viewItem.tag)
      return
    }
    
    setFocusToTextField(withTag: previousViewItem.tag)
  }
  
  func handleNonEmptyText(_ replacementText: String, _ viewItem: PinTextFieldViewItem) {
    guard let nextViewItem = nextViewItemFrom(tag: viewItem.tag) else {
      return
    }
    
    setFocusToTextField(withTag: nextViewItem.tag)
  }
  
  func setFocusToTextField(withTag tag: Int) {
    codeViewItems.forEach {
      $0.isInFocus = $0.tag == tag
    }
  }
  
  func updateTextFieldsForMultipleCharacters(_ replacementText: String) {
    replacementText.enumerated().forEach { index, character in
      guard let item = codeViewItems.first(where: { $0.tag == index }) else {
        return
      }
      item.text = String(character)
    }
    
    let tag = replacementText.count >= codeLength ? codeLength - 1 : replacementText.count
    setFocusToTextField(withTag: tag)
  }
  
  func onTextFieldBackPressed(viewItem: PinTextFieldViewItem) {
    if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
      previousViewItem.text = .empty
      setFocusToTextField(withTag: previousViewItem.tag)
    }
    
    sendCode()
  }
  
  func nextViewItemFrom(tag: Int) -> PinTextFieldViewItem? {
    let nextTextItemTag = tag + 1
    
    guard nextTextItemTag < codeViewItems.count else {
      return nil
    }
    return codeViewItems.first(where: { $0.tag == nextTextItemTag })
  }
  
  func previousViewItemFrom(tag: Int) -> PinTextFieldViewItem? {
    let previousTextItemTag = tag - 1
    
    guard previousTextItemTag >= 0 else {
      return nil
    }
    return codeViewItems.first(where: { $0.tag == previousTextItemTag })
  }
  
  func sendCode() {
    let generateCode: String? = codeViewItems.reduce(into: "") { partialResult, textFieldViewItem in
      partialResult.append(textFieldViewItem.text)
    }
    
    guard let generateCode else {
      return
    }
    code = generateCode
  }
}
