import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import Factory
import AccountData

@MainActor
public protocol EnterCVVCodeViewModelProtocol: ObservableObject {
  // Published Properties
  var isShowSetPinSuccessPopup: Bool { get set }
  var isShown: Bool { get set }
  var isShowIndicator: Bool { get set }
  var isCVVCodeEntered: Bool { get set }
  var generatedCVV: String { get set }
  var cvvCodeValue: String { get set }
  var toastMessage: String? { get set }

  // Normal Properties
  var cardID: String { get }
  var cvvCodeDigits: Int { get }
  var pinViewItems: [PinTextFieldViewItem] { get set }
  
  init(cardID: String)
  
  // API
  func verifyCVVCode(completion: @escaping (String) -> Void)
  
  // View Helpers
  func onReceivedCVVCode(cvvCode: String)
  func textFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem)
  func onTextFieldBackPressed(viewItem: PinTextFieldViewItem)
}

// MARK: - Common Functions
public extension EnterCVVCodeViewModelProtocol {
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
