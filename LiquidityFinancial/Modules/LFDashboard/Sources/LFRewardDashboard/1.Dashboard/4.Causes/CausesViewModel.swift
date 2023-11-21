import Foundation
import LFRewards
import Factory
import RewardData
import RewardDomain
import LFUtilities
import LFLocalizable
import Combine

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
  @Published var isLoadingFundraisers: CauseModel?
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  private var subscribers: Set<AnyCancellable> = []
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  init() {
    handleSelectedFundraisersSuccess()
  }
  
  func appearOpeations() {
    switch status {
    case .idle:
      apiFetchCategories()
    default:
      break
    }
  }
  
  func retryTapped() {
    apiFetchCategories()
  }
  
  func selected(fundraiser: CategoriesTrendingModel) {
    self.navigation = .fundraiserDetail(fundraiser.id ?? "")
  }
  
  func selected(cause: CauseModel) {
    apiFetchCategoriesFundraisers(cause: cause)
  }
  
  func getCauseName(from id: String) -> String? {
    let cause = self.donationCategories.first(where: { $0.id == id })
    return cause?.name
  }
  
  func handleSelectedFundraisersSuccess() {
    NotificationCenter.default.publisher(for: .selectedFundraisersSuccess)
      .delay(for: 0.65, scheduler: RunLoop.main)
      .sink { [weak self] _ in
        guard let self, self.rewardDataManager.fundraisersDetail != nil else { return }
        LFUtilities.popToRootView()
        self.navigation = nil
      }
      .store(in: &subscribers)
  }
  
}

  // MARK: - API logic

extension CausesViewModel {
  private func apiFetchCategories() {
    Task {
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
  
  private func apiFetchCategoriesFundraisers(cause: CauseModel) {
    Task {
      defer { isLoadingFundraisers = nil }
      isLoadingFundraisers = cause
      do {
        let fundraisers = try await rewardUseCase.getCategoriesFundraisers(categoryID: cause.id, limit: limit, offset: offset)
        let fundraiserModels = fundraisers.data.compactMap({ FundraiserModel(fundraiserData: $0) })
        rewardDataManager.update(fundraisers: fundraisers)
        navigation = .selectFundraiser(cause, fundraiserModels)
      } catch {
        log.error(error.localizedDescription)
        showError = true
      }
    }
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
    case fundraiserDetail(String)
  }
}
