import Foundation
import Factory
import SolidData
import SolidDomain
import LFUtilities
import LFLocalizable
import Combine

@MainActor
final class CardsTabViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  
  lazy var getListSolidCardUseCase: SolidGetListCardUseCaseProtocol = {
    SolidGetListCardUseCase(repository: solidCardRepository)
  }()
  
  @Published var isInitiating: Bool = false
  @Published var toastMessage: String?

  @Published var selectedTab: CardListType = .open
  @Published var status: DataStatus<CardModel> = .idle
  @Published var filteredCardsList: [CardModel] = []
  
  @Published var navigation: Navigation?
  
  let cardListType: [CardListType] = [.open, .closed]
  
  private var cardsList: [CardModel] = []
  private var subscribers: Set<AnyCancellable> = []

  init() {
    apiFetchSolidCards()
    observeSelectedTab()
  }
}

// MARK: - API Hanlder
private extension CardsTabViewModel {
  func apiFetchSolidCards() {
    Task {
      do {
        let cards = try await getListSolidCardUseCase.execute()
        cardsList = mapToListCardModel(from: cards)
        filterCardsList(with: selectedTab)
      } catch {
        status = .failure(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension CardsTabViewModel {
  func refresh() {
    apiFetchSolidCards()
  }
  
  func navigateToCardDetail(card: CardModel) {
    navigation = .cardDetail(card: card)
  }
}

// MARK: - Private Functions
private extension CardsTabViewModel {
  func observeSelectedTab() {
    $selectedTab
      .receive(on: DispatchQueue.main)
      .sink { [weak self] tab in
        guard let self, !cardsList.isEmpty else { return }
        self.filterCardsList(with: tab)
      }
      .store(in: &subscribers)
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
        cardName: "Default CardName", // Update later after the api is available
        cardType: CardType(rawValue: $0.type) ?? .virtual,
        cardholderName: nil,
        expiryMonth: Int($0.expirationMonth) ?? 0,
        expiryYear: Int($0.expirationYear) ?? 0,
        last4: $0.panLast4,
        popularBackgroundColor: nil, // Update in phase 3
        popularTextColor: nil, // Update in phase 3
        cardStatus: CardStatus(rawValue: $0.cardStatus) ?? .unactivated
      )
    }
  }
}

// MARK: - Types
extension CardsTabViewModel {
  enum CardListType: Identifiable {
    case open
    case closed
    
    var id: String {
      switch self {
      case .open:
        return "open"
      case .closed:
        return "closed"
      }
    }
    
    var title: String {
      switch self {
      case .open:
        return L10N.Common.Card.OpenCards.title
      case .closed:
        return L10N.Common.Card.CloseCards.title
      }
    }
  }
  
  enum Navigation {
    case cardDetail(card: CardModel)
  }
}
