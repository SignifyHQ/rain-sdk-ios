import Foundation
import Combine

@MainActor
final class ListCardsViewModel: ObservableObject {
  @Published var cardsList: [CardModel] = []
  @Published var currentCard: CardModel = .virtualDefault
  @Published var toastMessage: String?
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var present: Presentation?
  @Published var navigation: Navigation?
  @Published var isActive: Bool = false
  
  private var bag = Set<AnyCancellable>()
  var isHasPhysicalCard: Bool {
    cardsList.contains { card in
      card.cardType == .physical
    }
  }
  
  init() {
    getListCard()
    $currentCard.sink { [weak self] card in
      guard let self = self else { return }
      self.isActive = card.cardStatus == .active
      self.isCardLocked = card.cardStatus == .disabled
    }
    .store(in: &bag)
  }
}

// MARK: - API
private extension ListCardsViewModel {
  func callLockCardAPI() {
    // TODO: Will be implemented later
    // Success
    updateCardLock(status: .disabled, id: currentCard.id) // FAKE API
  }
  
  func callUnLockCardAPI() {
    // TODO: Will be implemented later
    // Success
    updateCardLock(status: .active, id: currentCard.id) // FAKE API
  }
  
  func getListCard() {
    // FAKEDATA
    cardsList = [
      CardModel.virtualDefault,
      CardModel.physicalDefault
    ]
    currentCard = cardsList.first ?? CardModel.virtualDefault
  }
  
  func updateCardLock(status: CardStatus, id: String) {
    guard id == currentCard.id else { return }
    currentCard.cardStatus = status
    isCardLocked = status == .disabled
    isActive = status == .active
  }
}

// MARK: - View Helpers
extension ListCardsViewModel {
  func dealsAction() {
    // TODO: Will be implemented later
    // doshManager.showRewards()
  }
  
  func lockCardToggled() {
    switch currentCard.cardStatus {
    case .active:
      callLockCardAPI()
    case .disabled:
      callUnLockCardAPI()
    default:
      break
    }
  }
  
  func onClickedChangePinButton() {
    if currentCard.cardStatus == .active {
      present = .setCardPin(currentCard)
    } else {
      presentActivateCardView()
    }
  }
  
  func onClickedAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    present = .applePay(currentCard)
  }
  
  func onChangeCurrentCard() {
    isShowCardNumber = false
    isCardLocked = currentCard.cardStatus == .disabled
  }
  
  func onClickedOrderPhysicalCard() {
    navigation = .orderPhysicalCard
  }
  
  func onClickedActiveCard() {
    presentActivateCardView()
  }
}

// MARK: - Private Functions
private extension ListCardsViewModel {
  func presentActivateCardView() {
    switch currentCard.cardType {
    case .physical:
      present = .activatePhysicalCard(currentCard)
    case .virtual:
      present = .activateVirtualCard(currentCard)
    }
  }
}

// MARK: - Types
extension ListCardsViewModel {
  enum Presentation: Identifiable {
    case setCardPin(CardModel)
    case addAppleWallet(CardModel)
    case applePay(CardModel)
    case activateVirtualCard(CardModel)
    case activatePhysicalCard(CardModel)
    
    var id: String {
      switch self {
      case .setCardPin:
        return "setCardPin"
      case .addAppleWallet:
        return "addAppleWallet"
      case .applePay:
        return "applePay"
      case .activatePhysicalCard:
        return "activatePhysicalCard"
      case .activateVirtualCard:
        return "activateVirtualCard"
      }
    }
  }
  
  enum Navigation {
    case orderPhysicalCard
  }
}
