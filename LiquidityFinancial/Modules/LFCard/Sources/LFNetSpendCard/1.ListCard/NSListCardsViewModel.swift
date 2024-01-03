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
import BaseCard
import SwiftUI

@MainActor
public final class NSListCardsViewModel: ListCardsViewModelProtocol {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published public var isInit: Bool = false
  @Published public var isLoading: Bool = false
  @Published public var isShowCardNumber: Bool = false
  @Published public var isCardLocked: Bool = false
  @Published public var isActivePhysical: Bool = false
  @Published public var isHasPhysicalCard: Bool = false
  @Published public var isShowListCardDropdown: Bool = false
  @Published public var toastMessage: String?
  @Published public var cardsList: [CardModel] = []
  @Published public var cardMetaDatas: [CardMetaData?] = []
  @Published public var currentCard: CardModel = .virtualDefault
  @Published public var popup: ListCardPopup?
  
  unowned public let coordinator: BaseCardDestinationObservable
  public var isSwitchCard = true
  
  public var cancellables: Set<AnyCancellable> = []
  
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
  
  private var subscribers: Set<AnyCancellable> = []
  
  public init(coordinator: BaseCardDestinationObservable) {
    self.coordinator = coordinator
    apiFetchNetSpendCards()
    observeRefreshListCards()
  }
  
  private func observeRefreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        apiFetchNetSpendCards()
      }
      .store(in: &subscribers)
  }
}

// MARK: - API
public extension NSListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await lockCardUseCase.execute(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardStatus(status: .disabled, id: card.liquidityCardId)
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
        let card = try await unLockCardUseCase.execute(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardStatus(status: .active, id: card.liquidityCardId)
      } catch {
        isCardLocked = true
        isLoading = false
        toastMessage = error.localizedDescription
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
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
public extension NSListCardsViewModel {
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
  
  func orderPhysicalSuccess(card: CardModel) {
    isHasPhysicalCard = true
    cardMetaDatas.append(nil)
    cardsList.append(card)
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
      setFullScreenCoordinator(destinationView: .changePin)
    } else {
      presentActivateCardView(activeCardView: activeCardView)
    }
  }
  
  func onClickedAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    let destinationView = ApplePayViewController(
      viewModel: NSApplePayViewModel(cardModel: currentCard)
    )
    setSheetCoordinator(
      destinationView: .applePay(AnyView(destinationView))
    )
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
    let viewModel = NSOrderPhysicalCardViewModel(coordinator: coordinator) { card in
      self.orderPhysicalSuccess(card: card)
    }
    let destinationView = OrderPhysicalCardView(viewModel: viewModel, coordinator: coordinator)
    setNavigationCoordinator(
      destinationView: .orderPhysicalCard(AnyView(destinationView))
    )
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
      setFullScreenCoordinator(destinationView: .activatePhysicalCard(activeCardView))
    default:
      break
    }
  }
}

// MARK: API
extension NSListCardsViewModel {
  func apiFetchNetSpendCards() {
    isInit = true
    Task { @MainActor in
      do {
        
        let cards = try await getListNSCardUseCase.execute()
        cardsList = cards.map { card in
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
        
        isHasPhysicalCard = cardsList.contains { card in
          card.cardType == .physical
        }
        currentCard = cardsList.first ?? .virtualDefault
        isActivePhysical = currentCard.cardStatus == .active
        isCardLocked = currentCard.cardStatus == .disabled
        
        let filteredCards = cardsList.filter({ $0.cardStatus != .closed })
        if filteredCards.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          cardMetaDatas = Array(repeating: nil, count: filteredCards.count)
          filteredCards.map { $0.id }.enumerated().forEach { index, id in
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
