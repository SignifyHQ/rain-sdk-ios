import Foundation
import Combine
import Factory
import CardDomain
import CardData
import LFUtilities
import OnboardingData
import AccountData
import NetSpendData
import PassKit

@MainActor
final class ListCardsViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published var isInit: Bool = false
  @Published var isLoading: Bool = false
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var isActive: Bool = false
  @Published var cardsList: [CardModel] = []
  @Published var cardMetaDatas: [CardMetaData?] = []
  @Published var currentCard: CardModel = .virtualDefault
  @Published var present: Presentation?
  @Published var navigation: Navigation?
  @Published var toastMessage: String?
  
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
  }
}

// MARK: - API
private extension ListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await cardUseCase.lockCard(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardLock(status: .disabled, id: card.id)
      } catch {
        isCardLocked = false
        isLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func callUnLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await cardUseCase.unlockCard(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardLock(status: .active, id: card.id)
      } catch {
        isCardLocked = true
        isLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func getListCard() {
    isInit = true
    Task {
      do {
        let cards = try await cardUseCase.getListCard()
        cardsList = cards.map { card in
          mapToCardModel(card: card)
        }
        cardMetaDatas = Array(repeating: nil, count: cardsList.count)
        cardsList.map { $0.id }.enumerated().forEach { index, id in
          getCard(with: id, and: index)
        }
        currentCard = cardsList.first ?? .virtualDefault
        isInit = false
      } catch {
        isInit = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func getCard(with cardID: String, and index: Int) {
    Task {
      do {
        let card = try await cardUseCase.getCard(cardID: cardID, sessionID: accountDataManager.sessionID)
        if let usersession = netspendDataManager.sdkSession {
          let encryptedData: APICardEncrypted? = card.decodeData(session: usersession)
          if let encryptedData {
            cardMetaDatas[index] = CardMetaData(pan: encryptedData.pan, cvv: encryptedData.cvv2)
          }
        }
      } catch {
        isInit = false
        toastMessage = error.localizedDescription
      }
    }
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
    if currentCard.cardStatus == .active && isCardLocked {
      callLockCardAPI()
    } else if currentCard.cardStatus == .disabled && !isCardLocked {
      callUnLockCardAPI()
    }
  }
  
  func onClickedChangePinButton() {
    if currentCard.cardStatus == .active {
      present = .changePin(currentCard)
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
    isActive = currentCard.cardStatus == .active
    isCardLocked = currentCard.cardStatus == .disabled
    isShowCardNumber = false
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
  func mapToCardModel(card: CardEntity) -> CardModel {
    CardModel(
      id: card.id,
      cardType: CardType(rawValue: card.type) ?? .virtual,
      cardholderName: nil,
      expiryMonth: card.expirationMonth,
      expiryYear: card.expirationYear,
      last4: card.panLast4,
      cardStatus: CardStatus(rawValue: card.status) ?? .unactivated
    )
  }
  
  func presentActivateCardView() {
    switch currentCard.cardType {
    case .physical:
      present = .activatePhysicalCard(currentCard)
    default:
      break
    }
  }
  
  func updateCardLock(status: CardStatus, id: String) {
    isLoading = false
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id
    }) else { return }
    currentCard.cardStatus = status
    cardsList[index].cardStatus = status
    isActive = status == .active
  }
}

// MARK: - Types
extension ListCardsViewModel {
  enum Presentation: Identifiable {
    case changePin(CardModel)
    case addAppleWallet(CardModel)
    case applePay(CardModel)
    case activatePhysicalCard(CardModel)
    
    var id: String {
      switch self {
      case .changePin:
        return "changePin"
      case .addAppleWallet:
        return "addAppleWallet"
      case .applePay:
        return "applePay"
      case .activatePhysicalCard:
        return "activatePhysicalCard"
      }
    }
  }
  
  enum Navigation {
    case orderPhysicalCard
  }
}
