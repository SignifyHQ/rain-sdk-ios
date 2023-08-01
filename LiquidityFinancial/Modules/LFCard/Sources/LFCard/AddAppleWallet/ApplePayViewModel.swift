import Foundation
import CardDomain
import CardData
import Factory

@MainActor
final class ApplePayViewModel: ObservableObject {
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.accountDataManager) var accountDataManager

  private lazy var userCase: CardUseCase? = { [weak self] in
    guard let self else { return nil }
    return CardUseCase(repository: self.cardRepository)
  }()
  
  let cardModel: CardModel
  
  init(cardModel: CardModel) {
    self.cardModel = cardModel
  }
}

  // MARK: - View Helpers
extension ApplePayViewModel {
  func onViewAppear() {
    
  }
  
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> PostApplePayTokenEntity? {
    return try await userCase?.postApplePayToken(sessionId: accountDataManager.sessionID, cardId: cardModel.id, bodyData: bodyData)
  }
}
