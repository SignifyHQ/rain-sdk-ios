import Foundation
import LFRewards
import Factory
import RewardData
import RewardDomain
import LFUtilities
import LFLocalizable
import Combine

@MainActor
class PrideCardCauseViewModel: ObservableObject {
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  @Published var status = Status.idle
  @Published var navigation: Navigation?
  @Published var showError: String?
  
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
      initData()
    default:
      break
    }
  }
  
  func retryTapped() {
    initData()
  }
  
  func selectedItem(fundraiserID: String) {
    self.navigation = .fundraiserDetail(fundraiserID)
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

extension PrideCardCauseViewModel {
  private func initData() {
    Task { @MainActor in
      do {
        status = .loading
        let causeList = try await apiFetchCategories()
        if let causeItem = causeList.first {
          let fundraisers = try await apiFetchCategoriesFundraisers(causeItem: causeItem)
          status = .success(fundraisers)
        } else {
          status = .failure
        }
      } catch {
        status = .failure
        log.error(error.userFriendlyMessage)
        showError = error.userFriendlyMessage
      }
    }
  }
  
  private func apiFetchCategories() async throws -> [CauseModel] {
    let categories = try await rewardUseCase.getDonationCategories(limit: limit, offset: offset)
    rewardDataManager.update(rewardCategories: categories)
    let causeCategories = categories.data.compactMap({ CauseModel(rewardData: $0) })
    return causeCategories
  }
  
  private func apiFetchCategoriesFundraisers(causeItem: CauseModel) async throws -> [FundraiserModel] {
    let categoryId = causeItem.id
    let fundraisers = try await rewardUseCase.getCategoriesFundraisers(categoryID: categoryId, limit: limit, offset: offset)
    let fundraiserModels = fundraisers.data.compactMap({ FundraiserModel(fundraiserData: $0) })
    rewardDataManager.update(fundraisers: fundraisers)
    return fundraiserModels
  }
}

  // MARK: - Types

extension PrideCardCauseViewModel {
  enum Status {
    case idle
    case loading
    case success([FundraiserModel])
    case failure
  }
  
  enum Navigation {
    case fundraiserDetail(String)
  }
}
