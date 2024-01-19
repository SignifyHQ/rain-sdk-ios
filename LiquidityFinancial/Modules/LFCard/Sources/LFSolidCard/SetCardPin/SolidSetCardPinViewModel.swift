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

  @Published public var pinValue: String = .empty
  @Published public var toastMessage: String?
  
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
    
    observePinCodeInput()
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
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func setCardPIN(pinToken: String, solidCardID: String) {
    let param = [
      "pin": pinValue,
      "expiryMonth": convertMonthIntToString(monthNumber: cardModel.expiryMonth),
      "expiryYear": String(cardModel.expiryYear),
      "last4": cardModel.last4
    ] as [String: Any]
    
    vgsSetCardPin(solidCardID: solidCardID, tokenID: pinToken, params: param) { [weak self] status, error in
      guard let self else { return }
      
      if let error {
        self.isShowIndicator = false
        self.toastMessage = error.localizedString
      } else if status {
        self.onSetPinSuccess()
      }
    }
  }
  
  func vgsSetCardPin(
    solidCardID: String,
    tokenID: String,
    params: [String: Any],
    completion: @escaping (Bool, String?) -> Void
  ) {
    let path = "/v1/card/\(solidCardID)/pin"
    vgsCollect.customHeaders = ["sd-pin-token": tokenID]

    vgsCollect.sendData(path: path, method: .post, extraData: params as [String: Any]) { [weak self] response in
      guard let self else {
        completion(false, nil)
        return
      }
      
      switch response {
      case let .success(_, data, _):
        self.handleVGSSetPinSuccess(data: data, completion: completion)
      case let .failure(code, data, _, error):
        self.handleVGSSetPinFailure(
          code: code,
          data: data,
          error: error,
          completion: completion
        )
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
  
  func observePinCodeInput() {
    $pinValue
      .map { [weak self] otp in
        guard let self else {
          return false
        }
        return otp.count == self.pinCodeDigits
      }
      .assign(to: &$isPinEntered)
  }
}

// MARK: - Private Functions
private extension SolidSetCardPinViewModel {
  func handleVGSSetPinSuccess(data: Data?, completion: @escaping (Bool, String?) -> Void) {
    if let jsonData = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
      log.debug(jsonData)
    }
    completion(true, nil)
  }

  func handleVGSSetPinFailure(
    code: Int,
    data: Data?,
    error: Error?,
    completion: @escaping (Bool, String?) -> Void
  ) {
    guard let data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
      var errorMsg = "Error: Wrong Request, code: "
      switch code {
      case 400 ..< 499:
        errorMsg += String(code)
      case VGSErrorType.inputDataIsNotValid.rawValue where error is VGSError:
        errorMsg += String(code)
      default:
        errorMsg += String(code)
      }
      completion(false, errorMsg)
      return
    }
    
    let errorMessage = jsonData["message"] as? String
    log.error(jsonData)
    completion(false, errorMessage)
  }
  
  func convertMonthIntToString(monthNumber: Int) -> String? {
    switch monthNumber {
    case 1...9:
      // Convert to valid VGS expiryDate format: MM/YYYY
      return "0" + "\(monthNumber)"
    case 10...12:
      return "\(monthNumber)"
    default:
      return nil
    }
  }
}
