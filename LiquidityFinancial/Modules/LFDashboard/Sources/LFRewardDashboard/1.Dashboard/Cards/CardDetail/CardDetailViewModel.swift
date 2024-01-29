import Foundation
import Combine
import Factory
import SolidData
import SolidDomain
import LFStyleGuide
import LFUtilities
import LFLocalizable
import GeneralFeature
import VGSShowSDK
import Services
import SwiftUI

@MainActor
final class CardDetailViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService

  lazy var updateCardStatusUseCase: SolidUpdateCardStatusUseCaseProtocol = {
    SolidUpdateCardStatusUseCase(repository: solidCardRepository)
  }()
  
  lazy var closeCardUseCase: SolidCloseCardUseCaseProtocol = {
    SolidCloseCardUseCase(repository: solidCardRepository)
  }()
  
  @Published var isCardAvailable = false
  @Published var isShowListCardDropdown: Bool = false
  @Published var isCardClosed: Bool = false
  @Published var isCallingAPI: Bool = false
  @Published var toastMessage: String?
  
  @Published var spendingStatusIcon = GenImages.CommonImages.icPause
  @Published var cardsList: [CardModel] = []
  @Published var filterredCards: [CardModel] = []
  @Published var transactionsList: [TransactionModel] = []
  @Published var currentCard: CardModel = .default
  @Published var navigation: Navigation?
  @Published var popup: Popup?

  private var subscribers: Set<AnyCancellable> = []
  
  init(currentCard: CardModel, cardsList: [CardModel], filterredCards: [CardModel]) {
    self.cardsList = cardsList
    self.currentCard = currentCard
    self.filterredCards = filterredCards
    observeCurrentCard()
  }
}

// MARK: - API Handler
extension CardDetailViewModel {
  private func updateCardStatusAPI(with status: CardSpendingStatus) {
    Task {
      defer { isCallingAPI = false}
      isCallingAPI = true

      do {
        let parameters = APISolidCardStatusParameters(cardStatus: status.rawValue)
        let card = try await updateCardStatusUseCase.execute(cardID: currentCard.id, parameters: parameters)
        toastMessage = status.toastMessage
        updateCardStatus(status: status.mapToCardStatus(), id: card.id)
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func closeCardAPI() {
    Task {
      defer { isCallingAPI = false}
      isCallingAPI = true
      hidePopup()
      
      do {
        let isSuccess = try await closeCardUseCase.execute(cardID: currentCard.id)
        if isSuccess {
          updateCardStatus(status: .closed, id: currentCard.id)
        }
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handler
extension CardDetailViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onSwitchedCard(to card: CardModel) {
    currentCard = card
    isShowListCardDropdown.toggle()
  }
  
  func onClickedTransactionRow(transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func onClickedSeeAllButton() {
  }
  
  func onClickedTrashButton() {
    popup = .confirmationCloseCard
  }
  
  func updateCardSpendingStatus() {
    if currentCard.cardStatus == .active {
      analyticsService.track(event: AnalyticsEvent(name: .tapsLockCard))
      updateCardStatusAPI(with: .pause)
    } else if currentCard.cardStatus == .disabled {
      analyticsService.track(event: AnalyticsEvent(name: .tapsUnlockCard))
      updateCardStatusAPI(with: .resume)
    }
  }
  
  func navigateToEditCardName() {
    navigation = .editCardName
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Private Functions
private extension CardDetailViewModel {
  func observeCurrentCard() {
    $currentCard
      .receive(on: DispatchQueue.main)
      .sink { [weak self] card in
        guard let self else { return }
        self.isCardClosed = card.cardStatus == .closed
        self.spendingStatusIcon = card.cardStatus == .disabled
        ? GenImages.CommonImages.icPlay
        : GenImages.CommonImages.icPause
      }
      .store(in: &subscribers)
  }
  
  func postDidCardsListChangeNotification() {
    NotificationCenter.default.post(
      name: .didCardsListChange,
      object: nil,
      userInfo: [Constants.UserInfoKey.cards: cardsList]
    )
  }
    
  func updateCardStatus(status: CardStatus, id: String) {
    guard let index = cardsList.firstIndex(where: { $0.id == id }), id == currentCard.id else {
      return
    }
    
    currentCard.cardStatus = status
    cardsList[index].cardStatus = status
    postDidCardsListChangeNotification()
  }
}

// MARK: - Types
extension CardDetailViewModel {
  enum Navigation {
    case editCardName
    case transactionDetail(TransactionModel)
  }
  
  enum Popup {
    case confirmationCloseCard
  }
  
  enum CardSpendingStatus: String {
    case pause = "inactive"
    case resume = "active"
    
    var toastMessage: String {
      switch self {
      case .pause:
        return L10N.Common.Card.CardPause.title
      case .resume:
        return L10N.Common.Card.CardResume.title
      }
    }
    
    func mapToCardStatus() -> CardStatus {
      switch self {
      case .pause:
        return .disabled
      case .resume:
        return .active
      }
    }
  }
}
