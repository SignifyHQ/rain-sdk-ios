import LFUtilities
import Foundation

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
    // analyticsService.track(event: Event(name: EventName.tapsActivateCard.rawValue))
    // Call activeCard API
    cardActivated = cardDetails // Fake call api
  }
}
