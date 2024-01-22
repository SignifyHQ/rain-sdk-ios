import Foundation
import NetspendDomain
import Factory

@MainActor
public final class NSApplePayViewModel: ApplePayViewModelProtocol {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.accountDataManager) var accountDataManager

  lazy var postApplePayTokenUseCase: NSPostApplePayTokenUseCaseProtocol = {
    NSPostApplePayTokenUseCase(repository: cardRepository)
  }()
  
  public let cardModel: CardModel
  
  public init(cardModel: CardModel) {
    self.cardModel = cardModel
  }
}

// MARK: - API
extension NSApplePayViewModel {
  public func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> DigitalWalletLinkToken? {
    let response = try await postApplePayTokenUseCase.execute(
      sessionId: accountDataManager.sessionID,
      cardId: cardModel.id,
      bodyData: bodyData
    )
    return DigitalWalletLinkToken(
      activationData: response.activationData,
      ephemeralPublicKey: response.ephemeralPublicKey,
      encryptedCardData: response.encryptedCardData
    )
  }
}
