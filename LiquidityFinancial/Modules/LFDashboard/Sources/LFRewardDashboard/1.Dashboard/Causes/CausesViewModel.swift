import Foundation
import LFRewards
import Factory
import RewardData
import RewardDomain
import LFUtilities
import LFLocalizable

// swiftlint:disable force_unwrapping

@MainActor
class CausesViewModel: ObservableObject {
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  @Published var status = Status.idle
  @Published var donationCategories: [CauseModel] = []
  @Published var categoriesTrending: [CategoriesTrendingModel] = []
  @Published var navigation: Navigation?
  @Published var showError = false
  @Published var isLoading = false
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  let tabRedirection: TabRedirection
  init(tabRedirection: @escaping TabRedirection) {
    self.tabRedirection = tabRedirection
  }
  
  func appearOpeations() {
    switch status {
    case .idle:
      loadData()
    default:
      break
    }
  }
  
  func retryTapped() {
    loadData()
  }
  
  func selected(fundraiser: CategoriesTrendingModel) {
    
  }
  
  func selected(cause: CauseModel) {
    
  }
  
  func getCauseName(from id: String) -> String? {
    let cause = self.donationCategories.first(where: { $0.id == id })
    return cause?.name
  }
}

  // MARK: - API logic

extension CausesViewModel {
  private func loadData() {
    Task {
      defer { isLoading = false }
      isLoading = true
      status = .loading
      do {
        let categories = try await rewardUseCase.getDonationCategories(limit: limit, offset: offset)
        rewardDataManager.update(rewardCategories: categories)
        let causeCategories = categories.data.compactMap({ CauseModel(rewardData: $0) })
        self.donationCategories = causeCategories
        
        let categoriesTrending = try await rewardUseCase.getCategoriesTrending()
        let trendingModel = categoriesTrending.data.compactMap({ CategoriesTrendingModel(entity: $0) })
        self.categoriesTrending = trendingModel
        
        let data = Data(trending: trendingModel, causes: causeCategories)
        status = .success(data)
      } catch {
        status = .failure
        log.error(error.localizedDescription)
        showError = true
      }
    }
  }
  
  private func onFundraiserSelected() {
    navigation = nil
    tabRedirection(.rewards)
  }
}

  // MARK: - Types

extension CausesViewModel {
  enum Status {
    case idle
    case loading
    case success(Data)
    case failure
  }
  
  struct Data {
    let trending: [CategoriesTrendingModel]
    let causes: [CauseModel]
  }
  
  enum Navigation {
    case selectFundraiser(CauseModel, [FundraiserModel])
  }
}
