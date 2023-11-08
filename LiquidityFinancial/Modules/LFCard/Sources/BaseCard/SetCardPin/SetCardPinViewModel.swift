import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import Factory
import AccountData

@MainActor
public protocol SetCardPinViewModelProtocol: ObservableObject {
  // Published Properties
  var isShowSetPinSuccessPopup: Bool { get set }
  var isShown: Bool { get set }
  var isShowIndicator: Bool { get set }
  var isPinEntered: Bool { get set }
  var generatedPin: String { get set }
  var pinValue: String { get set }
  var toastMessage: String? { get set }
  
  // Normal Properties
  var pinViewItems: [PinTextFieldViewItem] { get set }
  var pinCodeDigits: Int { get }
  var cardModel: CardModel { get }
  var onFinish: ((String) -> Void)? { get }
  
  init(cardModel: CardModel, verifyID: String?, onFinish: ((String) -> Void)?)
    
  // View Helpers
  func onClickedContinueButton()
  func handleSuccessPrimaryAction(dismissScreen: @escaping () -> Void)
  func onReceivedPinCode(pinCode: String)
  func textFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem)
  func onTextFieldBackPressed(viewItem: PinTextFieldViewItem)
}

// MARK: - Functions
public extension SetCardPinViewModelProtocol {
  func onSetPinSuccess() {
    isShowIndicator = false
    if let onFinish {
      onFinish(cardModel.id)
    } else {
      isShowSetPinSuccessPopup = true
    }
  }
  
  func createTextFields() {
    for index in 0 ..< pinCodeDigits {
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
    if let pin = generatePin(), pin.count == pinCodeDigits {
      generatedPin = pin
    } else {
      generatedPin = ""
    }
  }
}
