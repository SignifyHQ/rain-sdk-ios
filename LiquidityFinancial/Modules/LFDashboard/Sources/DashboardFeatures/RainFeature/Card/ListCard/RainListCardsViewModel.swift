import Foundation
import LFStyleGuide
import Combine
import Factory
import RainData
import RainDomain
import LFUtilities
import OnboardingData
import AccountData
import PassKit
import Services
import LFLocalizable
import SwiftUI

@MainActor
public final class RainListCardsViewModel: ObservableObject {
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.rainService) var rainService

  lazy var lockCardUseCase: RainLockCardUseCaseProtocol = {
    RainLockCardUseCase(repository: rainCardRepository)
  }()
  
  lazy var unLockCardUseCase: RainUnlockCardUseCaseProtocol = {
    RainUnlockCardUseCase(repository: rainCardRepository)
  }()
  
  lazy var closeCardUseCase: RainCloseCardUseCaseProtocol = {
    RainCloseCardUseCase(repository: rainCardRepository)
  }()
  
  lazy var getCardsUseCase: RainGetCardsUseCaseProtocol = {
    RainGetCardsUseCase(repository: rainCardRepository)
  }()
  
  lazy var getSecretCardInformationUseCase: RainSecretCardInformationUseCaseProtocol = {
    RainSecretCardInformationUseCase(repository: rainCardRepository)
  }()
  
  @Published var isInit: Bool = false
  @Published var isLoading: Bool = false
  @Published var isShowCardNumber: Bool = false
  @Published var isCardLocked: Bool = false
  @Published var isActivePhysical: Bool = false
  @Published var isHasPhysicalCard: Bool = false
  @Published var isShowListCardDropdown: Bool = false
  @Published var toastMessage: String?
  
  @Published var cardsList: [CardModel] = []
  @Published var cardMetaDatas: [CardMetaData?] = []
  @Published var currentCard: CardModel = .virtualDefault
  @Published var navigation: Navigation?
  @Published var sheet: Sheet?
  @Published var fullScreen: FullScreen?
  @Published var popup: ListCardPopup?
  
  private var isSwitchCard = true
  private var subscribers: Set<AnyCancellable> = []
  
  public init() {
    fetchRainCards()
    observeRefreshListCards()
  }
}

// MARK: - API
extension RainListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await lockCardUseCase.execute(cardID: currentCard.id)
        updateCardStatus(status: .disabled, id: card.cardId ?? currentCard.id)
      } catch {
        isCardLocked = false
        isLoading = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func callUnLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await unLockCardUseCase.execute(cardID: currentCard.id)
        updateCardStatus(status: .active, id: card.cardId ?? currentCard.id)
      } catch {
        isCardLocked = true
        isLoading = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func closeCard() {
    Task {
      defer { isLoading = false }
      hidePopup()
      isLoading = true
      
      do {
        _ = try await closeCardUseCase.execute(cardID: currentCard.id)
        popup = .closeCardSuccessfully
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
public extension RainListCardsViewModel {
  func fetchRainCards() {
    Task {
      isInit = true
      
      do {
        let cards = try await getCardsUseCase.execute()
        cardsList = cards.map { card in
          mapToCardModel(card: card)
        }
        isHasPhysicalCard = cardsList.contains { card in
          card.cardType == .physical
        }
        
        cardsList = cardsList.filter({ $0.cardStatus != .closed })
        currentCard = cardsList.first ?? .virtualDefault
        isActivePhysical = currentCard.cardStatus == .active
        isCardLocked = currentCard.cardStatus == .disabled
        
        if cardsList.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          cardMetaDatas = Array(repeating: nil, count: cardsList.count)
          cardsList.enumerated().forEach { index, card in
            guard card.cardType == .virtual else {
              cardMetaDatas[index] = nil
              return
            }
            fetchSecretCardInformation(cardID: card.id, index: index)
          }
        }
      } catch {
        isInit = false
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func fetchSecretCardInformation(cardID: String, index: Int) {
    Task {
      defer { isInit = false }
      
      do {
        let sessionID = rainService.generateSessionId()
        let secretInformation = try await getSecretCardInformationUseCase.execute(sessionID: sessionID, cardID: cardID)
        
        let pan = rainService.decryptData(
          ivBase64: secretInformation.encryptedPanEntity.iv,
          dataBase64: secretInformation.encryptedPanEntity.data
        )
        let cvv = rainService.decryptData(
          ivBase64: secretInformation.encryptedCVCEntity.iv,
          dataBase64: secretInformation.encryptedCVCEntity.data
        )
        
        let cardMetaData = CardMetaData(pan: pan, cvv: cvv)
        cardMetaDatas[index] = cardMetaData
      } catch {
        cardMetaDatas[index] = nil
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension RainListCardsViewModel {
  func title(for card: CardModel) -> String {
    switch card.cardType {
    case .virtual:
      return L10N.Common.Card.Virtual.title + " **** " + card.last4
    case .physical:
      return L10N.Common.Card.Physical.title + " **** " + card.last4
    }
  }
  
  func onDisappear() {
    NotificationCenter.default.post(name: .refreshListCards, object: nil)
  }
  
  func activePhysicalSuccess(id: String) {
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id
    }) else { return }
    isSwitchCard = false
    currentCard.cardStatus = .active
    cardsList[index].cardStatus = .active
    isActivePhysical = true
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }

  func lockCardToggled() {
    if currentCard.cardStatus == .active && isCardLocked {
      analyticsService.track(event: AnalyticsEvent(name: .tapsLockCard))
      callLockCardAPI()
    } else if currentCard.cardStatus == .disabled && !isCardLocked {
      analyticsService.track(event: AnalyticsEvent(name: .tapsUnlockCard))
      callUnLockCardAPI()
    }
  }
  
  func onClickedAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    let destinationView = RainApplePayViewController(
      viewModel: RainApplePayViewModel(cardModel: currentCard)
    )
    sheet = .applePay(AnyView(destinationView))
  }
  
  func onChangeCurrentCard() {
    isActivePhysical = currentCard.cardStatus == .active
    isCardLocked = currentCard.cardStatus == .disabled
    if isSwitchCard {
      isShowCardNumber = false
    } else {
      isSwitchCard = true
    }
  }
  
  func onClickedOrderPhysicalCard() {
    let viewModel = RainOrderPhysicalCardViewModel { card in
      self.orderPhysicalSuccess(card: card)
    }
    let destinationView = RainOrderPhysicalCardView(viewModel: viewModel)
    navigation = .orderPhysicalCard(AnyView(destinationView))
  }
  
  func onClickCloseCardButton() {
    popup = .confirmCloseCard
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func primaryActionCloseCardSuccessfully(completion: @escaping () -> Void) {
    updateListCard(id: currentCard.id, completion: completion)
    popup = nil
  }
  
  func presentActivateCardView(activeCardView: AnyView) {
    switch currentCard.cardType {
    case .physical:
      fullScreen = .activatePhysicalCard(activeCardView)
    default:
      break
    }
  }
}

// MARK: - Private Functions
private extension RainListCardsViewModel {
  func observeRefreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        fetchRainCards()
      }
      .store(in: &subscribers)
  }
  
  func orderPhysicalSuccess(card: CardModel) {
    isHasPhysicalCard = true
    cardMetaDatas.append(nil)
    cardsList.insert(card, at: 0)
    currentCard = card
  }
  
  func mapToCardModel(card: RainCardEntity) -> CardModel {
    CardModel(
      id: card.cardId ?? card.rainCardId,
      cardType: CardType(rawValue: card.cardType) ?? .virtual,
      cardholderName: nil,
      expiryMonth: Int(card.expMonth ?? .empty) ?? 0,
      expiryYear: Int(card.expYear ?? .empty) ?? 0,
      last4: card.last4 ?? .empty,
      cardStatus: CardStatus(rawValue: card.cardStatus) ?? .unactivated
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
}
  
// MARK: - Types
extension RainListCardsViewModel {
  enum Navigation {
    case orderPhysicalCard(AnyView)
  }
  
  enum Sheet: Identifiable {
    case applePay(AnyView)
    
    public var id: String {
      switch self {
      case .applePay:
        return "applePay"
      }
    }
  }
  
  enum FullScreen: Identifiable {
    case activatePhysicalCard(AnyView)
    
    public var id: String {
      switch self {
      case .activatePhysicalCard:
        return "activatePhysicalCard"
      }
    }
  }
  
  enum ListCardPopup {
    case confirmCloseCard
    case closeCardSuccessfully
    case roundUpPurchases
  }
}
