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
  var pinValue: String { get set }
  var toastMessage: String? { get set }
  
  // Normal Properties
  var pinCodeDigits: Int { get }
  var cardModel: CardModel { get }
  var onFinish: ((String) -> Void)? { get }
  
  init(cardModel: CardModel, verifyID: String?, onFinish: ((String) -> Void)?)
    
  // View Helpers
  func onClickedContinueButton()
  func handleSuccessPrimaryAction(dismissScreen: @escaping () -> Void)
  func observePinCodeInput()
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
}
