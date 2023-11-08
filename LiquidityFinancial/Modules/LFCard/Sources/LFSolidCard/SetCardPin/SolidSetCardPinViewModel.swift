import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import SolidData
import SolidDomain
import Factory
import AccountData
import BaseCard
import Services
import VGSCollectSDK

@MainActor
public final class SolidSetCardPinViewModel: SetCardPinViewModelProtocol {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  
  @Published public  var isShowSetPinSuccessPopup: Bool = false
  @Published public var isShown: Bool = true
  @Published public var isShowIndicator: Bool = false
  @Published public var isPinEntered: Bool = false

  @Published public var generatedPin: String = .empty
  @Published public var pinValue: String = .empty
  @Published public var toastMessage: String?
  
  public var pinViewItems: [PinTextFieldViewItem] = .init()
  public let pinCodeDigits = Int(Constants.Default.pinCodeDigits.rawValue) ?? 4
  public let cardModel: CardModel
  public let onFinish: ((String) -> Void)?
  var vgsCollect = VGSCollect(id: LFServices.vgsConfig.id, environment: LFServices.vgsConfig.env)

  lazy var getPinTokenUseCase: SolidCreateCardPinTokenUseCaseProtocol = {
    SolidCreateCardPinTokenUseCase(repository: solidCardRepository)
  }()
  
  public init(cardModel: CardModel, verifyID: String? = nil, onFinish: ((String) -> Void)? = nil) {
    self.cardModel = cardModel
    self.onFinish = onFinish
    createTextFields()
  }
}

// MARK: - API Handle
extension SolidSetCardPinViewModel {
  public func onClickedContinueButton() {
    Task {
      isShowIndicator = true
      do {
        let response = try await getPinTokenUseCase.execute(cardID: cardModel.id)
        setCardPIN(pinToken: response.pinToken, solidCardID: response.solidCardId)
      } catch {
        isShowIndicator = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func setCardPIN(pinToken: String, solidCardID: String) {
    let param = [
      "pin": pinValue,
      "expiryMonth": String(cardModel.expiryMonth) ,
      "expiryYear": String(cardModel.expiryYear),
      "last4": cardModel.last4
    ] as [String: Any]
    
    vgsSetCardPin(solidCardID: solidCardID, tokenID: pinToken, params: param) { status, error in
      guard let error else {
        if status {
          self.onSetPinSuccess()
        }
        return
      }
      self.isShowIndicator = false
      self.toastMessage = error.localizedString
    }
  }
  
  func vgsSetCardPin(
    solidCardID: String,
    tokenID: String,
    params: [String: Any],
    completion: @escaping (Bool, String?) -> Void
  ) {
    let path = "/v1/card/\(solidCardID)/pin"

    vgsCollect.customHeaders = [
      "sd-pin-token": tokenID
    ]

    vgsCollect.sendData(path: path, method: .post, extraData: params as [String: Any]) { response in

      switch response {
      case let .success(_, data, _):
        if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          log.debug(jsonData)
          completion(true, nil)
        } else {
          completion(true, nil)
        }
        return
      case let .failure(code, _, _, error):
        var errorMsg = "Error: Wrong Request, code: "
        switch code {
        case 400 ..< 499:
          errorMsg += String(code)
        case VGSErrorType.inputDataIsNotValid.rawValue:
          if let error = error as? VGSError {
            errorMsg += String(code)
          }
        default:
          errorMsg += String(code)
        }
        completion(false, errorMsg)
        return
      }
    }
  }
}

// MARK: - View Helpers
public extension SolidSetCardPinViewModel {
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
