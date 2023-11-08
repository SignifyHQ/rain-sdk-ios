import Foundation
import LFStyleGuide
import Combine
import Factory
import SolidData
import SolidDomain
import LFUtilities
import OnboardingData
import AccountData
import PassKit
import RewardData
import RewardDomain
import Services
import LFLocalizable
import BaseCard
import SwiftUI

@MainActor
public final class SolidListCardsViewModel: ListCardsViewModelProtocol {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published public var isInit: Bool = false
  @Published public var isLoading: Bool = false
  @Published public var isShowCardNumber: Bool = false
  @Published public var isCardLocked: Bool = false
  @Published public var isActive: Bool = false
  @Published public var isUpdatingRoundUpPurchases = false
  @Published public var isShowListCardDropdown: Bool = false
  @Published public var toastMessage: String?
  @Published public var cardsList: [CardModel] = []
  @Published public var cardMetaDatas: [CardMetaData?] = []
  @Published public var currentCard: CardModel = .virtualDefault
  @Published public var popup: ListCardPopup?
  
  public unowned let coordinator: BaseCardDestinationObservable
  public var isSwitchCard = true
  
  public var roundUpPurchases: Bool {
    rewardDataManager.roundUpDonation ?? false
  }
  
  public var showRoundUpPurchases: Bool {
    LFUtilities.charityEnabled && rewardDataManager.currentSelectReward?.rawString == APIRewardType.donation.rawValue
  }
  
  public var cancellables: Set<AnyCancellable> = []
  
  lazy var updateCardStatusUseCase: SolidUpdateCardStatusUseCaseProtocol = {
    SolidUpdateCardStatusUseCase(repository: solidCardRepository)
  }()
  
  lazy var closeCardUseCase: SolidCloseCardUseCaseProtocol = {
    SolidCloseCardUseCase(repository: solidCardRepository)
  }()
  
  lazy var updateRoundUpDonationUseCase: SolidUpdateRoundUpDonationUseCaseProtocol = {
    SolidUpdateRoundUpDonationUseCase(repository: solidCardRepository)
  }()
  
  public init(cardData: Published<(CardData)>.Publisher, coordinator: BaseCardDestinationObservable) {
    self.coordinator = coordinator
    subscribeListCardsChange(cardData)
  }
}

// MARK: - API
public extension SolidListCardsViewModel {
  func callLockCardAPI() {
    isLoading = true
    Task {
      do {
        let cardStatus = "inactive"
        let parameters = APISolidCardStatusParameters(cardStatus: cardStatus)
        let card = try await updateCardStatusUseCase.execute(cardID: currentCard.id, parameters: parameters)
        updateCardStatus(status: .disabled, id: card.id)
      } catch {
        isCardLocked = false
        isLoading = false
        handleBackendError(error: error)
      }
    }
  }
  
  func callUnLockCardAPI() {
    isLoading = true
    Task {
      do {
        let cardStatus = "active"
        let parameters = APISolidCardStatusParameters(cardStatus: cardStatus)
        let card = try await updateCardStatusUseCase.execute(cardID: currentCard.id, parameters: parameters)
        updateCardStatus(status: .active, id: card.id)
      } catch {
        isCardLocked = true
        isLoading = false
        handleBackendError(error: error)
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
        let isSuccess = try await closeCardUseCase.execute(cardID: currentCard.id)
        if isSuccess {
          popup = .closeCardSuccessfully
        }
      } catch {
        handleBackendError(error: error)
      }
    }
  }
  
  func callUpdateRoundUpDonationAPI(status: Bool) {
    Task { @MainActor in
      defer { isUpdatingRoundUpPurchases = false }
      isUpdatingRoundUpPurchases = true
      do {
        let parameters = APISolidRoundUpDonationParameters(roundUpDonation: status)
        let response = try await updateRoundUpDonationUseCase.execute(cardID: currentCard.id, parameters: parameters)
        rewardDataManager.update(roundUpDonation: response.isRoundUpDonationEnabled ?? !status)
      } catch {
        handleBackendError(error: error)
      }
    }
  }
}

// MARK: - View Helpers
public extension SolidListCardsViewModel {
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
  
  func onClickedChangePinButton() {
    setFullScreenCoordinator(destinationView: .changePin)
  }
  
  func onClickedAddToApplePay() {
    guard currentCard.cardStatus == .active else {
      return
    }
    let destinationView = ApplePayViewController(
      viewModel: SolidApplePayViewModel(cardModel: currentCard)
    )
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
  
  func subscribeListCardsChange(_ cardData: Published<(CardData)>.Publisher) {
    cardData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cardData in
        guard let self = self else {
          return
        }
        self.isInit = cardData.loading
        self.cardsList = cardData.cards.filter { $0.cardStatus != .closed }
        self.cardMetaDatas = cardData.metaDatas
        self.currentCard = self.cardsList.first ?? .virtualDefault
        self.isActive = currentCard.cardStatus == .active
        self.isCardLocked = currentCard.cardStatus == .disabled
      }
      .store(in: &cancellables)
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
