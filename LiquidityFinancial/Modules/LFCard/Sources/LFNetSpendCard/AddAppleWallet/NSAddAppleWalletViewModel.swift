import Foundation
import NetspendDomain
import NetSpendData
import Factory
import BaseCard

@MainActor
public final class NSAddAppleWalletViewModel: AddAppleWalletViewModelProtocol {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published public var isShowApplePay: Bool = false
  
  private lazy var userCase: NSCardUseCase? = { [weak self] in
    guard let self else { return nil }
    return NSCardUseCase(repository: self.cardRepository)
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
  
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> PostApplePayTokenEntity? {
    try await userCase?.postApplePayToken(sessionId: accountDataManager.sessionID, cardId: cardModel.id, bodyData: bodyData)
  }
}
