import LFUtilities
import Foundation
import LFCard

@MainActor
final class CashCardViewModel: ObservableObject {
  @Published var isShowCardDetail = false
  @Published var cardActivated: CardModel?
  let cardDetails: CardModel

  init(cardDetails: CardModel) {
    self.cardDetails = cardDetails
  }
}

extension CashCardViewModel {
  func activeCard() {
    // TODO: Will be implemented later
    // Call activeCard API
    cardActivated = cardDetails // Fake call api
  }
}
