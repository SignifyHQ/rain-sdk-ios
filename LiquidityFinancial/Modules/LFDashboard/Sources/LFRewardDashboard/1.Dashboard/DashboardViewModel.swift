import Foundation
import RewardData
import Factory
import LFRewards

@MainActor
final class DashboardViewModel: ObservableObject {
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  @Published var toastMessage: String?

  let option: TabOption
  let tabRedirection: (TabOption) -> Void
  
  init(option: TabOption, tabRedirection: @escaping ((TabOption) -> Void)) {
    self.option = option
    self.tabRedirection = tabRedirection
  }
  
  var rewardType: UserRewardType {
    if let rewardType = rewardDataManager.currentSelectReward {
      switch rewardType.rawString {
      case UserRewardType.cashBack.rawValue:
        return .cashBack
      case UserRewardType.donation.rawValue:
        return .donation
      case UserRewardType.none.rawValue:
        return .none
      default:
        return .none
      }
    } else {
      return .none
    }
  }
}
