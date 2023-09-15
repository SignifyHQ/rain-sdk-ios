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
    switch LFUtilities.target {
    case .CauseCard:
      Task { @MainActor in
        do {
          defer { isLoading = false }
          isLoading = true
          let causeList = try await apiFetchCategories()
          self.navigation = .causeFilter(causeList)
        } catch {
          log.error(error.localizedDescription)
          showError = true
        }
      }
    case .PrideCard:
      Task { @MainActor in
        do {
          defer { isLoading = false }
          isLoading = true
          let causeList = try await apiFetchCategories()
          if let causeItem = causeList.first {
            let fundraisers = try await apiFetchCategoriesFundraisers(causeItem: causeItem)
            self.navigation = .selectFundraiser(causeItem, fundraisers)
          } else {
              //This cause never happen
            self.navigation = .causeFilter(causeList)
          }
        } catch {
          log.error(error.localizedDescription)
          showError = true
        }
      }
    default: break
    }
  }

  func cashbackNavigation() {
    navigation = .agreement
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
  
  private func apiFetchCategories() async throws -> [CauseModel] {
    let categories = try await selectRewardUseCase.getDonationCategories(limit: limit, offset: offset)
    rewardDataManager.update(rewardCategories: categories)
    let causeCategories = categories.data.compactMap({ CauseModel(rewardData: $0) })
    return causeCategories
  }
  
  private func apiFetchCategoriesFundraisers(causeItem: CauseModel) async throws -> [FundraiserModel] {
    let categoryId = causeItem.id
    let fundraisers = try await selectRewardUseCase.getCategoriesFundraisers(categoryID: categoryId, limit: limit, offset: offset)
    let fundraiserModels = fundraisers.data.compactMap({ FundraiserModel(fundraiserData: $0) })
    rewardDataManager.update(fundraisers: fundraisers)
    return fundraiserModels
  }
}

// MARK: - Types

extension SelectRewardsViewModel {
  enum Option: String {
    case cashback
    case donation

    var userRewardType: UserRewardType {
      switch self {
      case .cashback: return .cashBack
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
    case selectFundraiser(CauseModel, [FundraiserModel])
  }
}
