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
public final class NSEnterCVVCodeViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository

  @Published public var isShowSetPinSuccessPopup: Bool = false
  @Published public var isShown: Bool = true
  @Published public var isShowIndicator: Bool = false
  @Published public var isCVVCodeEntered: Bool = false
  
  @Published public var generatedCVV: String = .empty
  @Published public var toastMessage: String?
  
  public let cardID: String
  public let cvvCodeDigits = Int(Constants.Default.cvvCodeDigits.rawValue) ?? 3
  public var pinViewItems: [PinTextFieldViewItem] = .init()
  
  lazy var verifyCardUseCase: NSVerifyCVVCodeUseCaseProtocol = {
    NSVerifyCVVCodeUseCase(repository: cardRepository)
  }()
  
  public init(cardID: String) {
    self.cardID = cardID
    
    createTextFields()
    observeCVVInput()
  }
}

// MARK: - API Handle
public extension NSEnterCVVCodeViewModel {
  func verifyCVVCode(completion: @escaping (String) -> Void) {
    Task {
      isShowIndicator = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let encryptedData = try session.encryptWithJWKSet(
          value: [Constants.NetSpendKey.verificationValue.rawValue: generatedCVV]
        )
        let request = VerifyCVVCodeParameters(
          verificationType: Constants.NetSpendKey.cvc.rawValue, encryptedData: encryptedData
        )
        let response = try await verifyCardUseCase.execute(
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
public extension NSEnterCVVCodeViewModel {
  func observeCVVInput() {
    $generatedCVV
      .map { [weak self] cvv in
        guard let self else { return false }
        return cvv.count == cvvCodeDigits
      }
      .assign(to: &$isCVVCodeEntered)
  }
  
  func textFieldTextChange(replacementText: String, viewItem: PinTextFieldViewItem) {
    if replacementText.isEmpty, viewItem.text.isEmpty {
      if let previousViewItem = previousViewItemFrom(tag: viewItem.tag) {
        previousViewItem.text = .empty
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
      previousViewItem.text = .empty
      viewItem.isInFocus = false
      previousViewItem.isInFocus = true
    }
    sendPin()
  }
}

// MARK: - Private Functions
private extension NSEnterCVVCodeViewModel {
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
    if let pin = generatePin() {
      generatedCVV = pin
    }
  }
}
