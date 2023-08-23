import Foundation
import LFUtilities
import RewardData
import RewardDomain
import Factory
import LFRewards

@MainActor
class EditRewardsViewModel: ObservableObject {
  class RewardsViewModel: Identifiable {
    var id: String = UUID().uuidString
    var rewardSelecting: UserRewardType
    var isSelect: Bool
    
    init(rewardSelecting: UserRewardType, isSelect: Bool) {
      self.rewardSelecting = rewardSelecting
      self.isSelect = isSelect
    }
  }
  
  @Published var rowModel: [RewardsViewModel] = []
  @Published var showError = false
  @Published var isLoading = false

  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  var rowModelSelecting: RewardsViewModel?
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  init() {
    rowModel = [
      RewardsViewModel(rewardSelecting: .cashBack, isSelect: false),
      RewardsViewModel(rewardSelecting: .donation, isSelect: false)
    ]
    updateRewardSelected()
  }
  
  func selection(_ item: RewardsViewModel) -> UserRewardRowView.Selection {
    if isLoading {
      if item.id == rowModelSelecting?.id {
        return .loading
      }
      return .unselected
    } else {
      switch item.rewardSelecting {
      case .cashBack:
        return item.isSelect ? .selected : .unselected
      case .donation:
        return item.isSelect ? .selected : .unselected
      default:
        return .unselected
      }
    }
  }
  
  private func updateRewardSelected() {
    guard let rewardTypeRaw = rewardDataManager.currentSelectReward, let rewardType = UserRewardType(rawValue: rewardTypeRaw.rawString) else { return }
    switch rewardType {
    case .cashBack:
      let news = [
        RewardsViewModel(rewardSelecting: .cashBack, isSelect: true),
        RewardsViewModel(rewardSelecting: .donation, isSelect: false)
      ]
      rowModel = news
      rowModelSelecting = news.first(where: { $0.isSelect })
    case .donation:
      let news = [
        RewardsViewModel(rewardSelecting: .cashBack, isSelect: false),
        RewardsViewModel(rewardSelecting: .donation, isSelect: true)
      ]
      rowModel = news
      rowModelSelecting = news.first(where: { $0.isSelect })
    default:
      rowModel.forEach({ $0.isSelect = false })
    }
  }
  
  func optionTapped(_ item: RewardsViewModel) {
    rowModelSelecting = item
    apiSelecteRewardType(option: item.rewardSelecting)
  }
  
  private var selected: UserRewardType? {
    if let rewardTypeRaw = rewardDataManager.currentSelectReward, let rewardType = UserRewardType(rawValue: rewardTypeRaw.rawString) {
      return rewardType
    }
    return nil
  }
  
  private func apiSelecteRewardType(option: UserRewardType) {
    let param: [String: Any] = [
      "updateRewardTypeRequest": [
        "rewardType": option.rawValue
      ]
    ]
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        _ = try await rewardUseCase.selectReward(body: param)
        if let fundraiserID = accountDataManager.userInfomationData.userSelectedFundraiserID {
          try await apiFetchDetailFundraiser(fundraiserID: fundraiserID)
        }
        switch option {
        case .cashBack:
          rewardDataManager.update(currentSelectReward: APIRewardType.cashBack)
          updateRewardSelected()
        case .donation:
          rewardDataManager.update(currentSelectReward: APIRewardType.donation)
          updateRewardSelected()
        default: break
        }
      } catch {
        updateRewardSelected()
        log.error("Failed to select reward \(error.localizedDescription)")
        showError = true
      }
    }
  }
  
  func apiFetchDetailFundraiser(fundraiserID: String) async throws {
    let enity = try await rewardUseCase.getFundraisersDetail(fundraiserID: fundraiserID)
    rewardDataManager.update(fundraisersDetail: enity)
  }
}
