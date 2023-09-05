import Foundation
import LFStyleGuide
import Combine
import Factory
import NetSpendData
import NetSpendDomain
import LFUtilities
import OnboardingData
import AccountData
import PassKit
import RewardData
import RewardDomain

@MainActor
public final class ListCardsViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
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
  
  @Published var roundUpPurchasesPopup: Bool = false
  @Published var isUpdatingRoundUpPurchases = false
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  private var cancellable = Set<AnyCancellable>()
  
  var isHasPhysicalCard: Bool {
    cardsList.contains { card in
      card.cardType == .physical
    }
  }
  
  var roundUpPurchases: Bool {
    rewardDataManager.roundUpDonation ?? false
  }
  
  var showRoundUpPurchases: Bool {
    false //TODO: currently the feature is disable
  }
  
  public init(cardData: Published<(CardData)>.Publisher) {
    cardData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cardData in
        guard let self = self else {
          return
        }
        self.isInit = cardData.loading
        self.cardsList = cardData.cards
        self.cardMetaDatas = cardData.metaDatas
        self.currentCard = cardData.cards.first ?? .virtualDefault
      }
      .store(in: &cancellable)
  }
}

// MARK: - API
extension ListCardsViewModel {
  private func callLockCardAPI() {
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
  
  private func callUnLockCardAPI() {
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
extension ListCardsViewModel {
  func onDisappear() {
    currentCard = cardsList.first ?? .virtualDefault
    isShowCardNumber = false
  }
  
  func orderPhysicalSuccess(card: CardModel) {
    cardMetaDatas.append(nil)
    cardsList.append(card)
  }
  
  func activePhysicalSuccess(id: String) {
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id
    }) else { return }
    currentCard.cardStatus = .active
    cardsList[index].cardStatus = .active
    isActive = true
  }
  
  func openIntercom() {
    intercomService.openIntercom()
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
