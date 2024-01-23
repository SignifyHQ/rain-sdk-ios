import Foundation
import LFStyleGuide
import Combine
import Factory
import NetSpendData
import NetspendDomain
import LFUtilities
import OnboardingData
import AccountData
import PassKit
import Services
import LFLocalizable
import SwiftUI

@MainActor
public final class NSListCardsViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  lazy var lockCardUseCase: NSLockCardUseCaseProtocol = {
    NSLockCardUseCase(repository: cardRepository)
  }()
  
  lazy var unLockCardUseCase: NSUnLockCardUseCaseProtocol = {
    NSUnLockCardUseCase(repository: cardRepository)
  }()
  
  lazy var closeCardUseCase: NSCloseCardUseCaseProtocol = {
    NSCloseCardUseCase(repository: cardRepository)
  }()
  
  lazy var getListNSCardUseCase: NSGetListCardUseCaseProtocol = {
    NSGetListCardUseCase(repository: cardRepository)
  }()
  
  lazy var getCardUseCase: NSGetCardUseCaseProtocol = {
    NSGetCardUseCase(repository: cardRepository)
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
    apiFetchNetSpendCards()
    observeRefreshListCards()
  }
}

// MARK: - API
extension NSListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await lockCardUseCase.execute(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardStatus(status: .disabled, id: card.liquidityCardId)
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
        let card = try await unLockCardUseCase.execute(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardStatus(status: .active, id: card.liquidityCardId)
      } catch {
        isCardLocked = true
        isLoading = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func closeCard() {
    Task {
      defer {
        isLoading = false
      }
      hidePopup()
      isLoading = true
      do {
        let request = CloseCardReasonParameters()
        _ = try await closeCardUseCase.execute(
          reason: request, cardID: currentCard.id, sessionID: accountDataManager.sessionID
        )
        popup = .closeCardSuccessfully
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
public extension NSListCardsViewModel {
  
  func title(for card: CardModel) -> String {
    switch card.cardType {
    case .virtual:
      return L10N.Common.Card.Virtual.title + " **** " + card.last4
    case .physical:
      return L10N.Common.Card.Physical.title + " **** " + card.last4
    }
  }
  
  func apiFetchNetSpendCards() {
    isInit = true
    Task { @MainActor in
      do {
        let cards = try await getListNSCardUseCase.execute()
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
          cardsList.map { $0.id }.enumerated().forEach { index, id in
            apiFetchNetSpendCardDetail(with: id, and: index)
          }
        }
      } catch {
        isInit = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func apiFetchNetSpendCardDetail(with cardID: String, and index: Int) {
    Task { @MainActor in
      defer { isInit = false }
      do {
        let entity = try await getCardUseCase.execute(cardID: cardID, sessionID: accountDataManager.sessionID)
        if let usersession = netspendDataManager.sdkSession, let cardModel = entity as? NSAPICard {
          let encryptedData: APICardEncrypted? = cardModel.decodeData(session: usersession)
          if let encryptedData {
            cardMetaDatas[index] = CardMetaData(pan: encryptedData.pan, cvv: encryptedData.cvv2)
          }
        }
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension NSListCardsViewModel {
  func title(for card: CardModel) -> String {
    switch card.cardType {
    case .virtual:
      return LFLocalizable.Card.Virtual.title + " **** " + card.last4
    case .physical:
      return LFLocalizable.Card.Physical.title + " **** " + card.last4
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
  
  func onClickedChangePinButton(activeCardView: AnyView) {
    if currentCard.cardStatus == .active {
      fullScreen = .changePin
    } else {
      presentActivateCardView(activeCardView: activeCardView)
    }
  }
  
  func onClickedAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    let destinationView = NSApplePayViewController(
      viewModel: NSApplePayViewModel(cardModel: currentCard)
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
    let viewModel = NSOrderPhysicalCardViewModel() { card in
      self.orderPhysicalSuccess(card: card)
    }
    let destinationView = NSOrderPhysicalCardView(viewModel: viewModel)
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
      fullScreen =  .activatePhysicalCard(activeCardView)
    default:
      break
    }
  }
}

// MARK: - Private Functions
private extension NSListCardsViewModel {
  func observeRefreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        apiFetchNetSpendCards()
      }
      .store(in: &subscribers)
  }
  
  func orderPhysicalSuccess(card: CardModel) {
    isHasPhysicalCard = true
    cardMetaDatas.append(nil)
    cardsList.append(card)
  }
  
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
}
  
// MARK: - Types
extension NSListCardsViewModel {
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
  
  enum ListCardPopup {
    case confirmCloseCard
    case closeCardSuccessfully
    case roundUpPurchases
  }
}
