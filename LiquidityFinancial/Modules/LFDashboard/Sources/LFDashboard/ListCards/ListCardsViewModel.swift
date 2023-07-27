import Foundation

@MainActor
final class ListCardsViewModel: ObservableObject {
  @Published var cardsList: [CardModel] = []
  @Published var currentCard: CardModel = .default
  @Published var toastMessage: String?
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var present: Presentation?
  @Published var popup: Popup?

  var isActive: Bool {
    currentCard.cardStatus == .active
  }
  
  var isHasPhysicalCard: Bool {
    cardsList.contains { card in
      card.cardType == .physical
    }
  }
  
  init() {
    getListCard()
  }
}

// MARK: - API
extension ListCardsViewModel {
  private func callLockCardAPI() {
    // TODO: Will be implemented later
  }
  
  func getListCard() {
    // FAKEDATA
    cardsList = [
      CardModel.default,
      CardModel(
        id: "12",
        cardType: .physical,
        cardholderName: "Fake name",
        currency: "222",
        expiryMonth: "2",
        expiryYear: "25",
        last4: "2222",
        cardStatus: .inactive,
        roundUpPurchases: true
      )
    ]
    currentCard = cardsList.first ?? CardModel.default
    isCardLocked = currentCard.cardStatus == .inactive
  }
  
  func updateCardLock(status: CardStatus, id: String) {
    guard id == currentCard.id else { return }
    currentCard.cardStatus = status
    isCardLocked = status == .inactive
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
    case .pendingActivation:
      popup = .activateCard
    case .active, .inactive:
      callLockCardAPI()
    default:
      break
    }
  }
  
  func onClickedChangePinButton() {
    if currentCard.cardStatus == .active {
      present = .setCardPin(currentCard)
    } else {
      present = .addAppleWallet(currentCard)
    }
  }
  
  func onClickedAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    present = .applePay(currentCard)
  }
  
  func activationAction() {
    popup = nil
    present = .addAppleWallet(currentCard)
  }
  
  func dismissPopup() {
    popup = nil
  }
  
  func onChangeCurrentCard() {
    isShowCardNumber = false
    isCardLocked = currentCard.cardStatus == .inactive
  }
  
  func onClickedOrderPhysicalCard() {
  }
  
  func onClickedActiveCard() {
  }
}

// MARK: - Types
extension ListCardsViewModel {
  enum Presentation: Identifiable {
    case setCardPin(CardModel)
    case addAppleWallet(CardModel)
    case applePay(CardModel)
    
    var id: String {
      switch self {
      case .setCardPin:
        return "setCardPin"
      case .addAppleWallet:
        return "addAppleWallet"
      case .applePay:
        return "applePay"
      }
    }
  }
  
  enum Popup {
    case activateCard
  }
}
