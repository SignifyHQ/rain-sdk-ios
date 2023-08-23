import Combine
import Foundation
import LFRewards
import Factory
import AccountData
import AccountDomain
import RewardData
import RewardDomain

@MainActor
class RewardViewModel: ObservableObject {
  @Published var type: UserRewardType = .none
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  let tabRedirection: TabRedirection
  private var cancellable: AnyCancellable?
  
  init(tabRedirection: @escaping TabRedirection) {
    self.tabRedirection = tabRedirection
    onAppear()
  }
  
  func onAppear() {
    if let rewardTypeRaw = rewardDataManager.currentSelectReward, let rewardType = UserRewardType(rawValue: rewardTypeRaw.rawString) {
      type = rewardType
    } else {
      type = .none
    }
  }
}
