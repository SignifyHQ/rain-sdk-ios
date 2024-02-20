import Foundation
import SolidFeature
import Factory
import AccountData
import SolidData
import SolidDomain
import LFUtilities
import LFLocalizable
import Combine

@MainActor
final class CardsTabViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager

  lazy var getListSolidCardUseCase: SolidGetListCardUseCaseProtocol = {
    SolidGetListCardUseCase(repository: solidCardRepository)
  }()
  
  @Published var toastMessage: String?

  @Published var selectedTab: CardListType = .open
  @Published var status: DataStatus<CardModel> = .idle
  @Published var cardsList: [CardModel] = []

  @Published var navigation: Navigation?
  
  let cardListType: [CardListType] = [.open, .closed]
  
  private var subscribers: Set<AnyCancellable> = []

  init() {
    apiFetchSolidCards()
    observeSelectedTab()
    observeDidCardsListChangeNotification()
    observeDidCardCreateSuccessNotification()
  }
  
  var noCardTitle: String {
    selectedTab == .open ? L10N.Common.Card.NoOpenCard.title : L10N.Common.Card.NoClosedCard.title
  }
}

// MARK: - API Handler
extension CardsTabViewModel {
   private func apiFetchSolidCards(completion: (() -> Void)? = nil) {
    Task {
      defer {
        completion?()
      }
      
      do {
        let cards = try await getListSolidCardUseCase.execute(isContainClosedCard: true)
        cardsList = mapToListCardModel(from: cards)
        filterCardsList(with: selectedTab)
      } catch {
        status = .failure(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handler
extension CardsTabViewModel {
  func refresh() {
    apiFetchSolidCards()
  }
  
  func navigateToCardDetail(card: CardModel, filterredCards: [CardModel]) {
    if featureFlagManager.isFeatureFlagEnabled(.virtualCardPhrase1) {
      let viewModel = CardDetailViewModel(
        currentCard: card,
        cardsList: cardsList,
        filterredCards: filterredCards
      )
      navigation = .cardDetail(viewModel)
      return
    }
    
    let viewModel = SolidListCardsViewModel(selectCardId: card.id)
    navigation = .cardListDetail(viewModel)
  }
  
  func onClickedCreateNewCardButton() {
    let cards = cardsList.filter({ $0.cardStatus != .closed && $0.cardType == .virtual })
    
    if cards.count < 5 {
      navigation = .createCard
    } else {
      toastMessage = L10N.Common.Card.CreateCardLimit.toastMessage
    }
  }
}

// MARK: - Private Functions
private extension CardsTabViewModel {
  func observeSelectedTab() {
    $selectedTab
      .receive(on: DispatchQueue.main)
      .dropFirst()
      .sink { [weak self] tab in
        guard let self else { return }
        self.filterCardsList(with: tab)
      }
      .store(in: &subscribers)
  }
  
  func observeDidCardsListChangeNotification() {
    NotificationCenter.default.publisher(for: .didCardsListChange)
      .sink { [weak self] notification in
        guard let self, let cardsList = notification.userInfo?[Constants.UserInfoKey.cards] as? [CardModel] else {
          return
        }
        self.cardsList = cardsList
        filterCardsList(with: self.selectedTab)
      }
      .store(in: &subscribers)
  }
  
  func observeDidCardCreateSuccessNotification() {
    NotificationCenter.default.publisher(for: .didCardCreateSuccess)
      .sink { [weak self] notification in
        guard let self, let card = notification.userInfo?[Constants.UserInfoKey.card] as? CardModel else {
          return
        }
        didCardCreateSuccess(card: card)
      }
      .store(in: &subscribers)
  }
  
  func didCardCreateSuccess(card: CardModel) {
    let filterredCards = cardsList.filter({ $0.cardStatus != .closed })
    
    apiFetchSolidCards()
    navigateToCardDetail(card: card, filterredCards: filterredCards)
  }
  
  func filterCardsList(with selectedTab: CardListType) {
    var cards = [CardModel]()
    switch selectedTab {
    case .open:
      cards = cardsList.filter({ $0.cardStatus != .closed })
    case .closed:
      cards = cardsList.filter({ $0.cardStatus == .closed })
    }
    
    status = .success(cards)
  }
  
  func mapToListCardModel(from entities: [SolidCardEntity]) -> [CardModel] {
    entities.map {
      CardModel(
        id: $0.id,
        cardName: $0.name,
        cardType: CardType(rawValue: $0.type) ?? .virtual,
        cardholderName: nil,
        expiryMonth: Int($0.expirationMonth) ?? 0,
        expiryYear: Int($0.expirationYear) ?? 0,
        last4: $0.panLast4,
        popularBackgroundColor: nil, // TODO: MinhNguyen - Update in phase 3
        popularTextColor: nil, // TODO: MinhNguyen - Update in phase 3
        cardStatus: CardStatus(rawValue: $0.cardStatus) ?? .unactivated
      )
    }
  }
}

// MARK: - Types
extension CardsTabViewModel {
  enum Navigation {
    case cardDetail(CardDetailViewModel)
    case cardListDetail(SolidListCardsViewModel)
    case createCard
  }
}
