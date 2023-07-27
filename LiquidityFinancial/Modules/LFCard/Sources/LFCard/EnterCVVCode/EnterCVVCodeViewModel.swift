import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities

@MainActor
final class EnterCVVCodeViewModel: ObservableObject {
  @Published var isShowSetPinSuccessPopup: Bool = false
  @Published var isShown: Bool = true
  @Published var isShowIndicator: Bool = false
  @Published var isCVVCodeEntered: Bool = false
  
  @Published var generatedCVV: String = ""
  @Published var cvvCodeValue: String = ""
  @Published var toastMessage: String?
  
  let cvvCodeDigits = Int(Constants.Default.cvvCodeDigits.rawValue) ?? 3
  private(set) var pinViewItems: [PinTextFieldViewItem] = .init()
  
  init() {
    createTextFields()
  }
}

// MARK: - API Handle
extension EnterCVVCodeViewModel {
  func verifyCVVCode(completion: @escaping () -> Void) {
    isShowIndicator = true
    // isVerifyCVVCodeSuccess
    // FAKE CALL API
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.isShowIndicator = false
      completion()
    }
  }
}

// MARK: - View Helpers
extension EnterCVVCodeViewModel {
  func onReceivedCVVCode(cvvCode: String) {
    isCVVCodeEntered = (cvvCode.count == cvvCodeDigits)
    cvvCodeValue = cvvCode
  }
  
  func textFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem) {
    if replacementText.isEmpty, viewItem.text.isEmpty {
      if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
        previousViewItem.text = ""
        viewItem.isInFocus = false
        previousViewItem.isInFocus = true
      }
    } else {
      if let nextViewItem = nextViewItemFrom(tag: viewItem.tag) {
        viewItem.isInFocus = false
        nextViewItem.isInFocus = true
      }
    }
    viewItem.text = replacementText
    sendPin()
  }
  
  func onTextFieldBackPressed(viewItem: PinTextFieldViewItem) {
    if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
      previousViewItem.text = ""
      viewItem.isInFocus = false
      previousViewItem.isInFocus = true
    }
    sendPin()
  }
}

// MARK: Private Functions
private extension EnterCVVCodeViewModel {
  func createTextFields() {
    for index in 0 ..< cvvCodeDigits {
      let viewItem = PinTextFieldViewItem(
        text: "",
        placeHolderText: "",
        isInFocus: index == 0,
        tag: index
      )
      pinViewItems.append(viewItem)
    }
  }
  
  func nextViewItemFrom(tag: Int) -> PinTextFieldViewItem? {
    let nextTextItemTag = tag + 1
    if nextTextItemTag < pinViewItems.count {
      return pinViewItems.first(where: { $0.tag == nextTextItemTag })
    }
    return nil
  }
  
  func previousViewItemFrom(tag: Int) -> PinTextFieldViewItem? {
    let previousTextItemTag = tag - 1
    if previousTextItemTag >= 0 {
      return pinViewItems.first(where: { $0.tag == previousTextItemTag })
    }
    return nil
  }
  
  func generatePin() -> String? {
    pinViewItems.reduce(into: "") { partialResult, textFieldViewItem in
      partialResult.append(textFieldViewItem.text)
    }
  }
  
  func sendPin() {
    if let pin = generatePin(), pin.count == cvvCodeDigits {
      generatedCVV = pin
    } else {
      generatedCVV = ""
    }
  }
}
