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
import Services
import LFLocalizable
import NetspendDomain

// MARK: - DestinationView
public struct ListCardsDestinationObservable {
  public var navigation: Navigation?
  public var sheet: Sheet?
  public var fullScreen: FullScreen?
  
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
  var isActivePhysical: Bool { get set }
  var isShowListCardDropdown: Bool { get set }
  var toastMessage: String? { get set }
  var cardsList: [CardModel] { get set }
  var cardMetaDatas: [CardMetaData?] { get set }
  var currentCard: CardModel { get set }
  var popup: ListCardPopup? { get set }
  
  // Properties
  var isSwitchCard: Bool { get set }
  var cancellables: Set<AnyCancellable> { get set }
  var coordinator: BaseCardDestinationObservable { get }
  
  // API
  func callLockCardAPI()
  func callUnLockCardAPI()
  func closeCard()
  
  // View Helpers
  func title(for card: CardModel) -> String
  func activePhysicalSuccess(id: String)
  func openSupportScreen()
  func lockCardToggled()
  func onClickedAddToApplePay()
  func onChangeCurrentCard()
  func onClickCloseCardButton()
  func hidePopup()
  func primaryActionCloseCardSuccessfully(completion: @escaping () -> Void)
}

public extension ListCardsViewModelProtocol {
  func subscribeListCardsChange(_ cardData: Published<(CardData)>.Publisher) {}
  func onDisappear() {}
}

// MARK: - Functions
public extension ListCardsViewModelProtocol {
  func mapToCardModel(card: NSCardEntity) -> CardModel {
    CardModel(
      id: card.liquidityCardId,
      cardType: CardType(rawValue: card.type) ?? .virtual,
      cardholderName: nil,
      expiryMonth: card.expirationMonth,
      expiryYear: card.expirationYear,
      last4: card.panLast4,
      cardStatus: CardStatus(rawValue: card.status) ?? .unactivated
    )
  }
  
  func updateCardStatus(status: CardStatus, id: String) {
    isLoading = false
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
    isSwitchCard = false
    currentCard.cardStatus = status
    cardsList[index].cardStatus = status
    isActivePhysical = status == .active
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
