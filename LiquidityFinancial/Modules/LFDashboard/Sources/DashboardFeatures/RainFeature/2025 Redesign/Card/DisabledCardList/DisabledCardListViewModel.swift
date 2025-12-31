import Combine
import SwiftUI
import LFUtilities
import Services
import RainDomain
import Factory
import LFStyleGuide
import MeaPushProvisioning

@MainActor
final class DisabledCardListViewModel: ObservableObject {
  @LazyInjected(\.rainService) var rainService
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  
  @Published var cardsList: [CardModel] = []
  @Published var currentCard: CardModel
  @Published var isShowCardNumber: Bool = false
  
  lazy var getSecretCardInformationUseCase: RainSecretCardInformationUseCaseProtocol = {
    RainSecretCardInformationUseCase(repository: rainCardRepository)
  }()
  
  var isShowingShowCardNumberCell: Bool {
    currentCard.cardType != .physical
    && cardsList.isNotEmpty
  }
  
  var closedTime: String? {
    if let updatedAt = currentCard.updatedAtDate {
      return LiquidityDateFormatter.dayMonthYearTimeWithAt.parseToString(from: updatedAt)
    }
    return nil
  }
  
  init(cards: [CardModel]) {
    self.cardsList = cards
      .filter({ $0.cardType != .physical })
      .sorted { ($0.updatedAtDate ?? .distantPast) >
        ($1.updatedAtDate ?? .distantPast) }
      .suffix(5)
      .reversed()
    self.currentCard = cards.last ?? .virtualDefault
    self.cardsList.removeLast()
  }
}

// MARK: Handle Interactions
extension DisabledCardListViewModel {
  func onCardItemTap(card: CardModel) {
    guard let tappedIndex = cardsList.firstIndex(where: { $0.id == card.id }) else {
      return
    }
    
    // Use a smoother animation
    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
      cardsList.remove(at: tappedIndex)
      cardsList.append(card)
      currentCard = card
      isShowCardNumber = false
    }
  }
}
