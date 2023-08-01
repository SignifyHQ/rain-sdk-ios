import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import CardDomain
import CardData
import Factory
import NetSpendData
import AccountData

@MainActor
final class SetCardPinViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published var isShowSetPinSuccessPopup: Bool = false
  @Published var isShown: Bool = true
  @Published var isShowIndicator: Bool = false
  @Published var isPinEntered: Bool = false

  @Published var generatedPin: String = ""
  @Published var pinValue: String = ""
  @Published var toastMessage: String?
  
  let pinCodeDigits = Int(Constants.Default.pinCodeDigits.rawValue) ?? 4
  private(set) var pinViewItems: [PinTextFieldViewItem] = .init()
  let verifyID: String
  let cardID: String
  let onFinish: (() -> Void)?
  
  lazy var cardUseCase: CardUseCaseProtocol = {
    CardUseCase(repository: cardRepository)
  }()
  
  init(verifyID: String, cardID: String, onFinish: (() -> Void)? = nil) {
    self.verifyID = verifyID
    self.cardID = cardID
    self.onFinish = onFinish
    createTextFields()
  }
}

// MARK: - API Handle
extension SetCardPinViewModel {
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
        isShowIndicator = false
        isShowSetPinSuccessPopup = true
      } catch {
        isShowIndicator = false
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
extension SetCardPinViewModel {
  func handleSuccessPrimaryAction(dismissScreen: @escaping () -> Void) {
    isShowSetPinSuccessPopup = false
    isShown = false
    closeAction(dismissScreen: dismissScreen)
  }
  
  func closeAction(dismissScreen: () -> Void) {
    if let onFinish {
      onFinish()
    } else {
      dismissScreen()
    }
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

// MARK: Private Functions
private extension SetCardPinViewModel {
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
