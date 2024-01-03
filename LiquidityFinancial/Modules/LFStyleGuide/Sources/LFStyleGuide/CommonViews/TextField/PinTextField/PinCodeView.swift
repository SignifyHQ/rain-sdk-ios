import SwiftUI
import LFUtilities

public struct PinCodeView: View {
  @State private var codeViewItems: [PinTextFieldViewItem] = .init()
  
  @Binding private var code: String
  @Binding private var isDisabled: Bool

  private let codeLength: Int
  private let pinCodeConfig: PinCodeConfig

  public init(
    code: Binding<String>,
    isDisabled: Binding<Bool> = .constant(false),
    codeLength: Int,
    pinCodeConfig: PinCodeView.PinCodeConfig = .default
  ) {
    _code = code
    _isDisabled = isDisabled
    self.codeLength = codeLength
    self.pinCodeConfig = pinCodeConfig
  }
  
  public var body: some View {
    HStack(spacing: 10) {
      ForEach(codeViewItems) { item in
        PinTextField(
          viewItem: item,
          isShown: true,
          onTextChange: { value in
            textFieldTextChange(replacementText: value, viewItem: item)
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
  }
  
  func textFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem) {
    guard replacementText.count <= 1 else {
      updateTextFieldsForMultipleCharacters(replacementText)
      sendCode()
      return
    }
    
    if replacementText.isEmpty, viewItem.text.isEmpty {
      handleEmptyText(viewItem)
    } else {
      handleNonEmptyText(replacementText, viewItem)
    }
    
    viewItem.text = replacementText
    sendCode()
  }
  
  func handleEmptyText(_ viewItem: PinTextFieldViewItem) {
    guard let previousViewItem = previousViewItemFrom(tag: viewItem.tag) else {
      return
    }
    
    previousViewItem.text = ""
    viewItem.isInFocus = false
    previousViewItem.isInFocus = true
  }
  
  func handleNonEmptyText(_ replacementText: String, _ viewItem: PinTextFieldViewItem) {
    guard let nextViewItem = nextViewItemFrom(tag: viewItem.tag) else {
      return
    }
    
    viewItem.isInFocus = false
    nextViewItem.isInFocus = true
  }
  
  func updateTextFieldsForMultipleCharacters(_ replacementText: String) {
    codeViewItems.forEach { item in
      let index = replacementText.index(
        replacementText.startIndex,
        offsetBy: item.tag,
        limitedBy: replacementText.endIndex
      )
      
      guard let index else {
        return
      }
      item.text = String(replacementText[index])
    }
  }
  
  func onTextFieldBackPressed(viewItem: PinTextFieldViewItem) {
    if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
      previousViewItem.text = .empty
      viewItem.isInFocus = false
      previousViewItem.isInFocus = true
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
