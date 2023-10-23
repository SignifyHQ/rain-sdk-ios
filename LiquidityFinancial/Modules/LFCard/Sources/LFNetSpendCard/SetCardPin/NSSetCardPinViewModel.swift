import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import NetspendDomain
import Factory
import AccountData
import BaseCard

@MainActor
public final class NSSetCardPinViewModel: SetCardPinViewModelProtocol {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published public  var isShowSetPinSuccessPopup: Bool = false
  @Published public var isShown: Bool = true
  @Published public var isShowIndicator: Bool = false
  @Published public var isPinEntered: Bool = false

  @Published public var generatedPin: String = .empty
  @Published public var pinValue: String = .empty
  @Published public var toastMessage: String?
  
  public var pinViewItems: [PinTextFieldViewItem] = .init()
  public let pinCodeDigits = Int(Constants.Default.pinCodeDigits.rawValue) ?? 4
  public let verifyID: String
  public let cardID: String
  public let onFinish: ((String) -> Void)?
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  public init(verifyID: String, cardID: String, onFinish: ((String) -> Void)? = nil) {
    self.verifyID = verifyID
    self.cardID = cardID
    self.onFinish = onFinish
    createTextFields()
  }
}

// MARK: - API Handle
public extension NSSetCardPinViewModel {
  func setCardPIN() {
    Task {
      isShowIndicator = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let encryptedData = try session.encryptWithJWKSet(
          value: [Constants.NetSpendKey.pin.rawValue: pinValue]
        )
        let request = APISetPinRequest(verifyId: verifyID, encryptedData: encryptedData)
        _ = try await cardUseCase.setPin(
          requestParam: request,
          cardID: cardID,
          sessionID: accountDataManager.sessionID
        )
        onSetPinSuccess()
      } catch {
        isShowIndicator = false
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
public extension NSSetCardPinViewModel {
  func handleSuccessPrimaryAction(dismissScreen: @escaping () -> Void) {
    isShowSetPinSuccessPopup = false
    isShown = false
    dismissScreen()
  }
  
  func onReceivedPinCode(pinCode: String) {
    isPinEntered = (pinCode.count == pinCodeDigits)
    pinValue = pinCode
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
