import Combine
import LFUtilities

@MainActor
final class DisabledCardListViewModel: ObservableObject {
  @Published var allVirtualCardsList: [CardModel] = []
  @Published var closedVirtualCardsList: [CardModel] = []
  @Published var currentCard: CardModel
  
  var usedCardCount: Int {
    allVirtualCardsList.count
  }
  
  var remainingCardCount: Int {
    Constants.virtualCardCountLimit - allVirtualCardsList.count
  }
  
  var hasReachedCardLimit: Bool {
    remainingCardCount <= 0
  }
  
  var closedTime: String? {
    if let updatedAt = currentCard.updatedAtDate {
      return LiquidityDateFormatter.dayMonthYearTimeWithAt.parseToString(from: updatedAt)
    }
    
    return "n/a"
  }
  
  init(
    cards: [CardModel]
  ) {
    self.allVirtualCardsList = cards
    self.closedVirtualCardsList = cards
      .filter {
        $0.cardStatus == .closed
      }
      .sorted {
        ($0.updatedAtDate ?? .distantPast) < ($1.updatedAtDate ?? .distantPast)
      }
    
    self.currentCard = cards.first ?? .virtualDefault
  }
}

// MARK: Handle Interactions
extension DisabledCardListViewModel {
  func onCardItemTap(
    card: CardModel
  ) {
    guard let tappedIndex = closedVirtualCardsList.firstIndex(where: { $0.id == card.id })
    else {
      return
    }
    
    closedVirtualCardsList.remove(at: tappedIndex)
    closedVirtualCardsList.append(card)
    
    currentCard = card
  }
}
