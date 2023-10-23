import SwiftUI
import Foundation
import LFStyleGuide
import Combine
import Factory
import NetSpendData
import LFUtilities
import OnboardingData
import AccountData
import PassKit
import RewardData
import RewardDomain
import LFServices
import LFLocalizable
import NetspendDomain

// MARK: - DestinationView
public struct ListCardsDestinationObservable {
  var navigation: Navigation?
  var sheet: Sheet?
  var fullScreen: FullScreen?
  
  public enum Navigation {
    case orderPhysicalCard(AnyView)
  }
  
  public enum Sheet: Identifiable {
    case applePay(AnyView)
    
    public var id: String {
      switch self {
      case .applePay:
        return "applePay"
      }
    }
  }
  
  public enum FullScreen: Identifiable {
    case changePin
    case activatePhysicalCard(AnyView)
    
    public var id: String {
      switch self {
      case .changePin:
        return "changePin"
      case .activatePhysicalCard:
        return "activatePhysicalCard"
      }
    }
  }
}

// MARK: - Popup
public enum ListCardPopup {
  case confirmCloseCard
  case closeCardSuccessfully
  case roundUpPurchases
}

@MainActor
public protocol ListCardsViewModelProtocol: ObservableObject {
  // Published Properties
  var isInit: Bool { get set }
  var isLoading: Bool { get set }
  var isShowCardNumber: Bool { get set }
  var isCardLocked: Bool { get set }
  var isActive: Bool { get set }
  var isUpdatingRoundUpPurchases: Bool { get set }
  var isHasPhysicalCard: Bool { get set }
  var isShowListCardDropdown: Bool { get set }
  var toastMessage: String? { get set }
  var cardsList: [CardModel] { get set }
  var cardMetaDatas: [CardMetaData?] { get set }
  var currentCard: CardModel { get set }
  var popup: ListCardPopup? { get set }
  
  // Properties
  var isSwitchCard: Bool { get set }
  var roundUpPurchases: Bool { get }
  var showRoundUpPurchases: Bool { get }
  var cancellables: Set<AnyCancellable> { get set }
  var coordinator: BaseCardDestinationObservable { get }
  
  init(cardData: Published<(CardData)>.Publisher, coordinator: BaseCardDestinationObservable)
  
  // API
  func callLockCardAPI()
  func callUnLockCardAPI()
  func closeCard()
  func callUpdateRoundUpDonationAPI(status: Bool)
  
  // View Helpers
  func title(for card: CardModel) -> String
  func onDisappear()
  func orderPhysicalSuccess(card: CardModel)
  func activePhysicalSuccess(id: String)
  func openSupportScreen()
  func lockCardToggled()
  func onClickedChangePinButton(activeCardView: AnyView)
  func onClickedAddToApplePay()
  func onClickedRoundUpPurchasesInformation()
  func onChangeCurrentCard()
  func onClickedOrderPhysicalCard()
  func onClickCloseCardButton()
  func hidePopup()
  func primaryActionCloseCardSuccessfully(completion: @escaping () -> Void)
}

// MARK: - Functions
public extension ListCardsViewModelProtocol {
  func subscribeListCardsChange(_ cardData: Published<(CardData)>.Publisher) {
    cardData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cardData in
        guard let self = self else {
          return
        }
        self.isInit = cardData.loading
        self.isHasPhysicalCard = cardData.cards.contains { card in
          card.cardType == .physical
        }
        self.cardsList = cardData.cards.filter { $0.cardStatus != .closed }
        self.cardMetaDatas = cardData.metaDatas
        self.currentCard = self.cardsList.first ?? .virtualDefault
        self.isActive = currentCard.cardStatus == .active
        self.isCardLocked = currentCard.cardStatus == .disabled
      }
      .store(in: &cancellables)
  }
  
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
  
  func presentActivateCardView(activeCardView: AnyView) {
    switch currentCard.cardType {
    case .physical:
      setFullScreenCoordinator(destinationView: .activatePhysicalCard(activeCardView))
    default:
      break
    }
  }
  
  func updateCardStatus(status: CardStatus, id: String) {
    isLoading = false
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    isSwitchCard = false
    currentCard.cardStatus = status
    cardsList[index].cardStatus = status
    isActive = status == .active
  }
  
  func updateListCard(id: String, completion: @escaping () -> Void) {
    isLoading = false
    guard let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    cardsList.remove(at: index)
    cardMetaDatas.remove(at: index)
    if let firstCard = cardsList.first {
      currentCard = firstCard
    } else {
      NotificationCenter.default.post(name: .noLinkedCards, object: nil)
      completion()
    }
  }
  
  func setNavigationCoordinator(destinationView: ListCardsDestinationObservable.Navigation) {
    coordinator.listCardsDestinationObservable.navigation = destinationView
  }
  
  func setSheetCoordinator(destinationView: ListCardsDestinationObservable.Sheet) {
    coordinator.listCardsDestinationObservable.sheet = destinationView
  }
  
  func setFullScreenCoordinator(destinationView: ListCardsDestinationObservable.FullScreen) {
    coordinator.listCardsDestinationObservable.fullScreen = destinationView
  }
}
