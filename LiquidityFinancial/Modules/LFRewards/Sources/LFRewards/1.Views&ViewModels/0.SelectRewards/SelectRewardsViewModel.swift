import Foundation
import Factory
import RewardData
import RewardDomain
import LFUtilities

@MainActor
class SelectRewardsViewModel: ObservableObject {
  @Published var selected: Option?
  @Published var isLoading = false
  @Published var navigation: Navigation?
  @Published var showError = false
  
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  lazy var selectRewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  var isContinueEnabled: Bool {
    selected != nil
  }

  func selection(_ option: Option) -> UserRewardRowView.Selection {
    selected == option ? .selected : .unselected
  }

  func optionSelected(_ option: Option) {
    selected = option
  }

  func continueTapped() {
    guard let selected = selected else { return }
    apiSelecteRewardType(option: selected)
  }

  func donationNavigation() {
    //analyticsService.track(event: Event(name: .selectedDonationReward))
    apiFetchCategories { [weak self] model in
      self?.navigation = .causeFilter(model)
    }
  }

  func cashbackNavigation() {
    //analyticsService.track(event: Event(name: .selectedCashbackReward))
    navigation = .agreement
  }
  
  private func apiFetchCategories(onCompletion: @escaping ([CauseModel]) -> Void) {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let categories = try await selectRewardUseCase.getDonationCategories(limit: limit, offset: offset)
        rewardDataManager.update(rewardCategories: categories)
        let causeCategories = categories.data.compactMap({ CauseModel(rewardData: $0) })
        onCompletion(causeCategories)
      } catch {
        log.error(error.localizedDescription)
        showError = true
      }
    }
  }
  
  private func apiSelecteRewardType(option: Option) {
    let param: [String: Any] = [
      "updateRewardTypeRequest": [
        "rewardType": option.apiRewardType.rawString
      ]
    ]
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        _ = try await selectRewardUseCase.selectReward(body: param)
        switch option {
        case .cashback:
          rewardDataManager.update(currentSelectReward: APIRewardType.cashBack)
          cashbackNavigation()
        case .donation:
          rewardDataManager.update(currentSelectReward: APIRewardType.donation)
          donationNavigation()
        }
      } catch {
        log.error(error.localizedDescription)
        showError = true
      }
    }
  }
}

// MARK: - Types

extension SelectRewardsViewModel {
  enum Option: String {
    case cashback
    case donation

    var userRewardType: UserRewardType {
      switch self {
      case .cashback: return .cashback
      case .donation: return .donation
      }
    }
    
    var apiRewardType: APIRewardType {
      switch self {
      case .cashback: return APIRewardType.cashBack
      case .donation: return APIRewardType.donation
      }
    }
  }

  enum Navigation {
    case agreement
    case causeFilter([CauseModel])
  }
}
