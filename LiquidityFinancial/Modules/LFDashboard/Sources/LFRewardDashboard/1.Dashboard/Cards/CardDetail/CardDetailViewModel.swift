import Foundation
import Combine
import Factory
import SolidData
import SolidDomain
import LFStyleGuide
import LFUtilities
import GeneralFeature
import VGSShowSDK
import Services
import SwiftUI

@MainActor
final class CardDetailViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  lazy var createVGSShowTokenUseCase: SolidCreateVGSShowTokenUseCaseProtocol = {
    SolidCreateVGSShowTokenUseCase(repository: solidCardRepository)
  }()
  
  @Published var isCardAvailable = false
  @Published var isShowListCardDropdown: Bool = false
  @Published var isCardClosed: Bool = false
  @Published var toastMessage: String?
  
  @Published var lockCardIcon = GenImages.CommonImages.icPause
  @Published var cardsList: [CardModel] = []
  @Published var transactionsList: [TransactionModel] = []
  @Published var currentCard: CardModel = .default
  @Published var navigation: Navigation?
  
  var vgsCardViewModel: VGSCardViewModel?
  private var subscribers: Set<AnyCancellable> = []

  init(currentCard: CardModel, cardsList: [CardModel]) {
    self.cardsList = cardsList
    self.currentCard = currentCard
    observeCurrentCard()
  }
}

// MARK: - API Handler
private extension CardDetailViewModel {
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
  }
  
  func onClickedLockCardButton() {
  }
  
  func navigateToEditCardName() {
    navigation = .editCardName
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
        self.lockCardIcon = card.cardStatus == .disabled
        ? GenImages.CommonImages.icPlay
        : GenImages.CommonImages.icPause
        self.vgsCardViewModel = VGSCardViewModel(card: card)
      }
      .store(in: &subscribers)
  }
}

// MARK: - Types
extension CardDetailViewModel {
  enum Navigation {
    case editCardName
    case transactionDetail(TransactionModel)
  }
}
