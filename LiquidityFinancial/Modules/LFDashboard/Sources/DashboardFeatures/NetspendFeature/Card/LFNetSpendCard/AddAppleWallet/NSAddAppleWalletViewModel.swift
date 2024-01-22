import Foundation
import NetspendDomain
import NetSpendData
import Factory

@MainActor
public final class NSAddAppleWalletViewModel: AddAppleWalletViewModelProtocol {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published public var isShowApplePay: Bool = false
  
  lazy var postApplePayTokenUseCase: NSPostApplePayTokenUseCaseProtocol = {
    NSPostApplePayTokenUseCase(repository: cardRepository)
  }()
  
  public let cardModel: CardModel
  public let onFinish: () -> Void

  public init(cardModel: CardModel, onFinish: @escaping () -> Void) {
    self.cardModel = cardModel
    self.onFinish = onFinish
  }
}

// MARK: - View Helpers
public extension NSAddAppleWalletViewModel {
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
