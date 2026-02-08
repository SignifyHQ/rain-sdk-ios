import Combine
import Factory
import LFUtilities

@MainActor
final class DisabledCardListViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var allVirtualCards: [CardModel] = []
  @Published var closedCards: [CardModel] = []
  @Published var currentCard: CardModel
  
  var usedVirtualCardCount: Int {
    allVirtualCards.count
  }
  
  var remainingVirtualCardCount: Int {
    Constants.virtualCardCountLimit - allVirtualCards.count
  }
  
  var hasReachedVirtualCardLimit: Bool {
    remainingVirtualCardCount <= 0
  }
  
  var closedTime: String? {
    if let updatedAt = currentCard.updatedAtDate {
      return LiquidityDateFormatter.dayMonthYearTimeWithAt.parseToString(from: updatedAt)
    }
    
    return "n/a"
  }
  
  init(
    allCards: [CardModel]
  ) {
    let closedCardsSorted = allCards
      .filter {
        $0.cardStatus == .closed
      }
      .sorted {
        ($0.updatedAtDate ?? .distantPast) < ($1.updatedAtDate ?? .distantPast)
      }
    
    self.allVirtualCards = allCards.filter {
      $0.cardType == .virtual
    }
    
    self.closedCards = closedCardsSorted
    self.currentCard = closedCardsSorted.first ?? .virtualDefault
  }
}

// MARK: Handle Interactions
extension DisabledCardListViewModel {
  func onCardItemTap(
    card: CardModel
  ) {
    guard let tappedIndex = closedCards.firstIndex(where: { $0.id == card.id })
    else {
      return
    }
    
    closedCards.remove(at: tappedIndex)
    closedCards.append(card)
    
    currentCard = card
  }
  
  func onCustomerSupportTap() {
    customerSupportService.openSupportScreen()
  }
}
