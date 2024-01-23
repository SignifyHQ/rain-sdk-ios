import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import NetspendDomain
import Factory
import AccountData

@MainActor
final class NSSetCardPinViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  lazy var setPinCardUseCase: NSSetCardPinUseCaseProtocol = {
    NSSetCardPinUseCase(repository: cardRepository)
  }()
  
  @Published var isShowSetPinSuccessPopup: Bool = false
  @Published var isShown: Bool = true
  @Published var isShowIndicator: Bool = false
  @Published var isPinEntered: Bool = false
  @Published var pinValue: String = .empty
  @Published var toastMessage: String?
  
  let pinCodeDigits = Constants.MaxCharacterLimit.cardPinCode.value
  let verifyID: String
  let cardModel: CardModel
  let onFinish: ((String) -> Void)?
  
  init(cardModel: CardModel, verifyID: String?, onFinish: ((String) -> Void)? = nil) {
    self.verifyID = verifyID ?? .empty
    self.cardModel = cardModel
    self.onFinish = onFinish
    
    observePinCodeInput()
  }
}

// MARK: - API Handler
extension NSSetCardPinViewModel {
  func onClickedContinueButton() {
    Task {
      isShowIndicator = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let encryptedData = try session.encryptWithJWKSet(
          value: [Constants.NetSpendKey.pin.rawValue: pinValue]
        )
        let request = APISetPinRequest(verifyId: verifyID, encryptedData: encryptedData)
        _ = try await setPinCardUseCase.execute(
          requestParam: request,
          cardID: cardModel.id,
          sessionID: accountDataManager.sessionID
        )
        onSetPinSuccess()
      } catch {
        isShowIndicator = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension NSSetCardPinViewModel {
  func handleSuccessPrimaryAction(dismissScreen: @escaping () -> Void) {
    isShowSetPinSuccessPopup = false
    isShown = false
    dismissScreen()
  }
}

// MARK: Private Functions
private extension NSSetCardPinViewModel {
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
  
  func onSetPinSuccess() {
    isShowIndicator = false
    if let onFinish {
      onFinish(cardModel.id)
    } else {
      isShowSetPinSuccessPopup = true
    }
  }
}
