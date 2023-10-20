import Foundation
import NetspendDomain
import NetSpendData
import Factory

@MainActor
final class AddAppleWalletViewModel: ObservableObject {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var isShowApplePay: Bool = false
  
  private lazy var userCase: NSCardUseCase? = { [weak self] in
    guard let self else { return nil }
    return NSCardUseCase(repository: self.cardRepository)
  }()
  
  let cardModel: CardModel
  let onFinish: () -> Void

  init(cardModel: CardModel, onFinish: @escaping () -> Void) {
    self.cardModel = cardModel
    self.onFinish = onFinish
  }
}

// MARK: - View Helpers
extension AddAppleWalletViewModel {
  func onViewAppear() {
    
  }
  
  func onClickedAddToApplePay() {
    isShowApplePay = true
  }
  
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> PostApplePayTokenEntity? {
    return try await userCase?.postApplePayToken(sessionId: accountDataManager.sessionID, cardId: cardModel.id, bodyData: bodyData)
  }
}
