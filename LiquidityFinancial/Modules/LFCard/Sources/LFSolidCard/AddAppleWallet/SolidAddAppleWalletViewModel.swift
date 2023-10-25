import Foundation
import NetspendDomain
import NetSpendData
import Factory
import BaseCard

@MainActor
public final class SolidAddAppleWalletViewModel: AddAppleWalletViewModelProtocol {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
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
public extension SolidAddAppleWalletViewModel {
  func onClickedAddToApplePay() {
    isShowApplePay = true
  }
  
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> PostApplePayTokenEntity? {
    try await postApplePayTokenUseCase.execute(
      sessionId: accountDataManager.sessionID,
      cardId: cardModel.id,
      bodyData: bodyData
    )
  }
}
