import Foundation
import SolidDomain
import SolidData
import Factory

@MainActor
final class SolidAddAppleWalletViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  
  lazy var postApplePayTokenUseCase: SolidCreateDigitalWalletUseCaseProtocol = {
    SolidCreateDigitalWalletUseCase(repository: solidCardRepository)
  }()
  
  @Published var isShowApplePay: Bool = false
  
  let cardModel: CardModel
  let onFinish: () -> Void

  init(cardModel: CardModel, onFinish: @escaping () -> Void) {
    self.cardModel = cardModel
    self.onFinish = onFinish
  }
}

// MARK: - View Helpers
extension SolidAddAppleWalletViewModel {
  func onClickedAddToApplePay() {
    isShowApplePay = true
  }
  
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> DigitalWalletLinkToken? {
    guard let certificates = bodyData["certificates"] as? [String],
        let deviceCert = certificates.first,
        let nonceSignature = bodyData["nonceSignature"] as? String,
        let nonce = bodyData["nonce"] as? String
    else {
      return nil
    }
    
    let parameters = APISolidApplePayWalletParameters(
      deviceCert: deviceCert,
      nonceSignature: nonceSignature,
      nonce: nonce
    )
    let response = try await postApplePayTokenUseCase.execute(
      cardID: cardModel.id,
      parameters: parameters
    )
    
    return DigitalWalletLinkToken(
      activationData: response.applePayEntity?.activationData,
      ephemeralPublicKey: response.applePayEntity?.ephemeralPublicKey,
      encryptedCardData: response.applePayEntity?.encryptedPassData
    )
  }
}
