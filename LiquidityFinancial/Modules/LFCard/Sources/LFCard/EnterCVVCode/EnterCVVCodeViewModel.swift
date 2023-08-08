import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import NetSpendDomain
import Factory
import AccountData

@MainActor
final class EnterCVVCodeViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository

  @Published var isShowSetPinSuccessPopup: Bool = false
  @Published var isShown: Bool = true
  @Published var isShowIndicator: Bool = false
  @Published var isCVVCodeEntered: Bool = false
  
  @Published var generatedCVV: String = ""
  @Published var cvvCodeValue: String = ""
  @Published var toastMessage: String?
  
  let cardID: String
  let cvvCodeDigits = Int(Constants.Default.cvvCodeDigits.rawValue) ?? 3
  private(set) var pinViewItems: [PinTextFieldViewItem] = .init()
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  init(cardID: String) {
    self.cardID = cardID
    createTextFields()
  }
}

// MARK: - API Handle
extension EnterCVVCodeViewModel {
  func verifyCVVCode(completion: @escaping (String) -> Void) {
    Task {
      isShowIndicator = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let encryptedData = try session.encryptWithJWKSet(
          value: [Constants.NetSpendKey.verificationValue.rawValue: cvvCodeValue]
        )
        let request = VerifyCVVCodeParameters(
          verificationType: Constants.NetSpendKey.cvc.rawValue, encryptedData: encryptedData
        )
        let response = try await cardUseCase.verifyCVVCode(
          requestParam: request,
          cardID: cardID,
          sessionID: accountDataManager.sessionID
        )
        isShowIndicator = false
        completion(response.id)
      } catch {
        isShowIndicator = false
        toastMessage = error.localizedDescription
      }
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
