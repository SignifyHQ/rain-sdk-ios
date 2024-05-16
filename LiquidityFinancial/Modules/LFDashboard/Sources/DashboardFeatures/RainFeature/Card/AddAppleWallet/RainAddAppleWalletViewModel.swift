import Foundation
import NetspendDomain
import NetSpendData
import Factory

@MainActor
final class RainAddAppleWalletViewModel: ObservableObject {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  lazy var postApplePayTokenUseCase: NSPostApplePayTokenUseCaseProtocol = {
    NSPostApplePayTokenUseCase(repository: cardRepository)
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
extension RainAddAppleWalletViewModel {
  func onClickedAddToApplePay() {
    isShowApplePay = true
  }
  
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> DigitalWalletLinkToken? {
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
