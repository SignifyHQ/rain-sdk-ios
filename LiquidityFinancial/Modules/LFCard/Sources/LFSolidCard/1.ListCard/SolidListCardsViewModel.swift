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
  @Published public var isActivePhysical: Bool = false
  @Published public var isActivatingCard: Bool = false
  @Published public var isUpdatingRoundUpPurchases = false
  @Published public var isShowListCardDropdown: Bool = false
  @Published public var toastMessage: String?
  @Published public var cardsList: [CardModel] = []
  @Published public var cardMetaDatas: [CardMetaData?] = []
  @Published public var popup: ListCardPopup?
  @Published public var currentCard: CardModel = .virtualDefault
  
  @Published var cardLimitUIModel: SolidListCardsViewModel.CardLimitUIModel?
  private var cardLimitUIModelList: [CardLimitUIModel] = []
  
  public unowned let coordinator: BaseCardDestinationObservable
  public var isSwitchCard = true
  
  public var roundUpPurchases: Bool {
    rewardDataManager.roundUpDonation ?? false
  }
  
  public var showRoundUpPurchases: Bool {
    rewardDataManager.currentSelectReward?.rawString == APIRewardType.donation.rawValue
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
  
  lazy var activePhysicalCardUseCase: SolidActiveCardUseCaseProtocol = {
    SolidActiveCardUseCase(repository: solidCardRepository)
  }()
  
  lazy var getCardLimitsUseCase: SolidGetCardLimitsUseCaseProtocol = {
    SolidGetCardLimitsUseCase(repository: solidCardRepository)
  }()
  
  lazy var getListSolidCardUseCase: SolidGetListCardUseCaseProtocol = {
    SolidGetListCardUseCase(repository: solidCardRepository)
  }()
  
  private var subscribers: Set<AnyCancellable> = []
  
  public init(coordinator: BaseCardDestinationObservable) {
    self.coordinator = coordinator
    apiFetchSolidCards()
    observeCardsList()
    observeRefreshListCards()
  }
  
  func onAppear() {
    handleCurrentCardLimit()
  }
  
  private func observeRefreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        apiFetchSolidCards()
      }
      .store(in: &subscribers)
  }
}

// MARK: - API
public extension SolidListCardsViewModel {
  func activePhysicalCard(activeCardView: AnyView) {
    Task {
      defer { isActivatingCard = false }
      isActivatingCard = true
      do {
        let parameters = APISolidActiveCardParameters(
          expiryMonth: convertMonthIntToString(monthNumber: currentCard.expiryMonth) ?? .empty,
          expiryYear: String(currentCard.expiryYear),
          last4: currentCard.last4
        )
        let card = try await activePhysicalCardUseCase.execute(cardID: currentCard.id, parameters: parameters)
        self.activePhysicalSuccess(id: card.id)
        self.presentActivateCardView(activeCardView: activeCardView)
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
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
        toastMessage = error.userFriendlyMessage
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
        let isSuccess = try await closeCardUseCase.execute(cardID: currentCard.id)
        if isSuccess {
          popup = .closeCardSuccessfully
        }
      } catch {
        toastMessage = error.userFriendlyMessage
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
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func apiFetchSolidCards() {
    isInit = true
    Task { @MainActor in
      do {
        let cards = try await getListSolidCardUseCase.execute()
        let cardsArr = cards.map { card in
          CardModel(
            id: card.id,
            cardType: CardType(rawValue: card.type) ?? .virtual,
            cardholderName: nil,
            expiryMonth: Int(card.expirationMonth) ?? 0,
            expiryYear: Int(card.expirationYear) ?? 0,
            last4: card.panLast4,
            cardStatus: CardStatus(rawValue: card.cardStatus) ?? .unactivated
          )
        }
        let filteredCards = cardsArr.filter({ $0.cardStatus != .closed })
        if filteredCards.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          cardMetaDatas = Array(repeating: nil, count: filteredCards.count)
          isInit = false
        }
        currentCard = cardsArr.first ?? .virtualDefault
        cardsList = cardsArr
        isActivePhysical = currentCard.cardStatus == .active
        isCardLocked = currentCard.cardStatus == .disabled
        
      } catch {
        isInit = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - Card Limits
extension SolidListCardsViewModel {
  private func observeCardsList() {
    $cardsList
      .removeDuplicates()
      .sink { [weak self] items in
        guard let self, items.isNotEmpty else { return }
        handleListCardLimit()
      }
      .store(in: &subscribers)
  }
  
  func handleListCardLimit() {
    Task { @MainActor in
      await apiFetchAllCardLimit()
      handleCurrentCardLimit()
    }
  }
  
  func handleCurrentCardLimit() {
    cardLimitUIModel = nil
    guard let cardLimit = cardLimitUIModelList.first(where: { $0.id == currentCard.id }) else { return }
    cardLimitUIModel = cardLimit
  }
  
  private func apiFetchAllCardLimit() async {
    await cardsList.concurrentForEach { [weak self] cardItem in
      guard let self else { return }
      if let model = await getItemCardLimit(cardID: cardItem.id) {
        cardLimitUIModelList.append(model)
      }
    }
  }
  
  private func getItemCardLimit(cardID: String) async -> CardLimitUIModel? {
    guard !cardID.isEmpty else { return nil }
    do {
      let cardLimits = try await getCardLimitsUseCase.execute(cardID: cardID)
      return CardLimitUIModel(entity: cardLimits, cardID: cardID)
    } catch {
      return nil
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
    isActivePhysical = currentCard.cardStatus == .active
    isCardLocked = currentCard.cardStatus == .disabled
    if isSwitchCard {
      resetActionShowCardNumber()
    } else {
      isSwitchCard = true
    }
    handleCurrentCardLimit()
  }
  
  func onClickCloseCardButton() {
    popup = .confirmCloseCard
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func resetActionShowCardNumber() {
    isShowCardNumber = false
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

// MARK: - Private Functions
private extension SolidListCardsViewModel {
  func convertMonthIntToString(monthNumber: Int) -> String? {
    switch monthNumber {
    case 1...9:
      // Convert to valid VGS expiryDate format: MM/YYYY
      return "0" + "\(monthNumber)"
    case 10...12:
      return "\(monthNumber)"
    default:
      return nil
    }
  }
}
