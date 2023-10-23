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
import RewardData
import RewardDomain
import LFServices
import LFLocalizable
import BaseCard
import SwiftUI

@MainActor
public final class NSListCardsViewModel: ListCardsViewModelProtocol {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published public var isInit: Bool = false
  @Published public var isLoading: Bool = false
  @Published public var isShowCardNumber: Bool = false
  @Published public var isCardLocked: Bool = false
  @Published public var isActive: Bool = false
  @Published public var isUpdatingRoundUpPurchases = false
  @Published public var isHasPhysicalCard: Bool = false
  @Published public var isShowListCardDropdown: Bool = false
  @Published public var toastMessage: String?
  @Published public var cardsList: [CardModel] = []
  @Published public var cardMetaDatas: [CardMetaData?] = []
  @Published public var currentCard: CardModel = .virtualDefault
  @Published public var popup: ListCardPopup?
  
  unowned public let coordinator: BaseCardDestinationObservable
  public var isSwitchCard = true
  
  public var roundUpPurchases: Bool {
    rewardDataManager.roundUpDonation ?? false
  }
  
  public var showRoundUpPurchases: Bool {
    false //TODO: currently the feature is disable
  }
  
  public var cancellables: Set<AnyCancellable> = []
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  lazy var rewardUseCase: RewardUseCaseProtocol = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  public init(cardData: Published<(CardData)>.Publisher, coordinator: BaseCardDestinationObservable) {
    self.coordinator = coordinator
    subscribeListCardsChange(cardData)
  }
}

// MARK: - API
public extension NSListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let card = try await cardUseCase.lockCard(cardID: currentCard.id, sessionID: accountDataManager.sessionID)
        updateCardStatus(status: .disabled, id: card.id)
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
        updateCardStatus(status: .active, id: card.id)
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
        _ = try await cardUseCase.closeCard(
          reason: request, cardID: currentCard.id, sessionID: accountDataManager.sessionID
        )
        popup = .closeCardSuccessfully
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func callUpdateRoundUpDonationAPI(status: Bool) {
    Task { @MainActor in
      defer { isUpdatingRoundUpPurchases = false }
      isUpdatingRoundUpPurchases = true
      do {
        let body: [String: Any] = [
          "updateRoundUpDonationRequest": [
            "roundUpDonation": status
          ]
        ]
        let entity = try await rewardUseCase.setRoundUpDonation(body: body)
        rewardDataManager.update(roundUpDonation: entity.userRoundUpEnabled ?? false)
      } catch {
        log.error(error.localizedDescription)
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
    isActive = true
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
  
  func onClickedRoundUpPurchasesInformation() {
    popup = popup == .roundUpPurchases ? nil : .roundUpPurchases
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
    let destinationView = ApplePayViewController(cardModel: currentCard)
    setSheetCoordinator(
      destinationView: .applePay(AnyView(destinationView))
    )
  }
  
  func onChangeCurrentCard() {
    isActive = currentCard.cardStatus == .active
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
}
