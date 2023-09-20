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
  @Published var roundUpPurchasesPopup: Bool = false
  @Published var isUpdatingRoundUpPurchases = false
  @Published var isHasPhysicalCard: Bool = false
  @Published var cardsList: [CardModel] = []
  @Published var cardMetaDatas: [CardMetaData?] = []
  @Published var currentCard: CardModel = .virtualDefault
  @Published var present: Presentation?
  @Published var fullScreenPresent: FullScreenPresentation?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var toastMessage: String?
  
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  private var cancellable = Set<AnyCancellable>()
  
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
        self.isHasPhysicalCard = cardData.cards.contains { card in
          card.cardType == .physical
        }
        self.cardsList = cardData.cards.filter { $0.cardStatus != .closed }
        self.cardMetaDatas = cardData.metaDatas
        self.currentCard = self.cardsList.first ?? .virtualDefault
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
        updateCardStatus(status: .disabled, id: card.id)
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
extension ListCardsViewModel {
  func onDisappear() {
    currentCard = cardsList.first ?? .virtualDefault
    isShowCardNumber = false
  }
  
  func orderPhysicalSuccess(card: CardModel) {
    isHasPhysicalCard = true
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
      fullScreenPresent = .changePin(currentCard)
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
      fullScreenPresent = .activatePhysicalCard(currentCard)
    default:
      break
    }
  }
  
  func updateCardStatus(status: CardStatus, id: String) {
    isLoading = false
    guard id == currentCard.id, let index = cardsList.firstIndex(where: { $0.id == id }) else {
      return
    }
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
}

// MARK: - Types
extension ListCardsViewModel {
  enum Presentation: Identifiable {
    case addAppleWallet(CardModel)
    case applePay(CardModel)
    
    var id: String {
      switch self {
      case .addAppleWallet:
        return "addAppleWallet"
      case .applePay:
        return "applePay"
      }
    }
  }
  
  enum FullScreenPresentation: Identifiable {
    case changePin(CardModel)
    case activatePhysicalCard(CardModel)

    var id: String {
      switch self {
      case .changePin:
        return "changePin"
      case .activatePhysicalCard:
        return "activatePhysicalCard"
      }
    }
  }
  
  enum Navigation {
    case orderPhysicalCard
  }
  
  enum Popup {
    case confirmCloseCard
    case closeCardSuccessfully
  }
}
