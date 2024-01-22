import Foundation
import SolidDomain
import SolidData
import Factory

@MainActor
public final class SolidApplePayViewModel: ApplePayViewModelProtocol {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.accountDataManager) var accountDataManager

  lazy var postApplePayTokenUseCase: SolidCreateDigitalWalletUseCaseProtocol = {
    SolidCreateDigitalWalletUseCase(repository: solidCardRepository)
  }()
  
  public let cardModel: CardModel
  
  public init(cardModel: CardModel) {
    self.cardModel = cardModel
  }
}

// MARK: - API
extension SolidApplePayViewModel {
  public func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> DigitalWalletLinkToken? {
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
