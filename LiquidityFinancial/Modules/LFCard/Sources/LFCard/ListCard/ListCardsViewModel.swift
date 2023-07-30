import Foundation
import Combine
import Factory
import CardDomain
import CardData
import LFUtilities
import OnboardingData

@MainActor
final class ListCardsViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.userDataManager) var userDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  @Published var cardsList: [CardModel] = []
  @Published var currentCard: CardModel = .virtualDefault
  @Published var toastMessage: String?
  @Published var isInit: Bool = false
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var isActive: Bool = false
  @Published var present: Presentation?
  @Published var navigation: Navigation?
  
  lazy var cardUseCase: CardUseCaseProtocol = {
    CardUseCase(repository: cardRepository)
  }()
  
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
    Task {
      do {
        let card = try await cardUseCase.lockCard(cardID: currentCard.id, sessionID: userDataManager.sessionID)
        updateCardLock(status: .disabled, id: card.id)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func callUnLockCardAPI() {
    Task {
      do {
        let card = try await cardUseCase.unlockCard(cardID: currentCard.id, sessionID: userDataManager.sessionID)
        updateCardLock(status: .active, id: card.id)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func getListCard() {
    isInit = true
    Task {
      do {
        let cards = try await cardUseCase.getListCard()
        isInit = false
        cardsList = mapToCardModel(cards: cards)
        currentCard = cardsList.first ?? CardModel.virtualDefault
      } catch {
        isInit = false
        toastMessage = error.localizedDescription
      }
    }
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
  func openIntercom() {
    intercomService.openIntercom()
  }
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
  func mapToCardModel(cards: [CardEntity]) -> [CardModel] {
    cards.map { card in
      CardModel(
        id: card.id,
        cardType: CardType(rawValue: card.type) ?? .virtual,
        cardholderName: nil,
        expiryMonth: "\(card.expirationMonth)",
        expiryYear: "\(card.expirationYear)",
        last4: card.panLast4,
        cardStatus: CardStatus(rawValue: card.status) ?? .unactivated
      )
    }
  }
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
