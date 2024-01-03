import Foundation
import LFUtilities
import LFLocalizable
import Combine
import Factory
import RewardData
import RewardDomain

@MainActor
public class SearchFundraiserViewModel: ObservableObject {
  private var offset = 0
  private var limit = 100
  private var total = 0
  
  @Published var pagingState = PagingState.idle
  @Published var fundraisers: [FundraiserModel] = []
  @Published var searchText = ""
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  private let onSelect: () -> Void
  private var textObserver: AnyCancellable?
  
  public init(onSelect: @escaping () -> Void) {
    self.onSelect = onSelect
    subscribeToSearchText()
  }
  
  private func subscribeToSearchText() {
    textObserver = $searchText
      .debounce(for: 0.3, scheduler: DispatchQueue.main)
      .removeDuplicates()
      .sink { [weak self] _ in
        self?.searchFirstPage()
      }
  }
  
  func onFundraiserAppear(_ fundraiser: FundraiserModel) {
    if fundraisers.count >= total {
      return // No more pages to load
    }
    
    switch pagingState {
    case .loadingFirstPage, .loadingNextPage:
      return // Already loading
    default:
      break
    }
    
    guard let index = fundraisers.firstIndex(where: { $0.id == fundraiser.id }) else {
      return // No index
    }
    
    guard (fundraisers.count - index) <= PagingState.threshold else {
      return // Threshold not reached
    }
    
    pagingState = .loadingNextPage
    apiSearch(text: searchText)
  }
  
  private func searchFirstPage() {
    fundraisers = []
    if searchText.isEmpty {
      pagingState = .idle
    } else {
      pagingState = .loadingFirstPage
      apiSearch(text: searchText)
    }
  }
  
  private func apiSearch(text: String) {
    Task {
      do {
        let entity = try await rewardUseCase.searchFundraisers(texts: [text], limit: limit, offset: offset)
        total = entity.total
        fundraisers.append(contentsOf: entity.data.compactMap({ FundraiserModel(fundraiserData: $0) }))
        pagingState = .loaded
      } catch {
        log.error(error.userFriendlyMessage)
        pagingState = .failure
      }
    }
  }
}
