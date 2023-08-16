import Foundation
import Factory
import RewardDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var rewardAPI: Factory<RewardAPIProtocol> {
    self {
      LFNetwork<RewardRoute>()
    }
  }
  
  public var rewardRepository: Factory<RewardRepositoryProtocol> {
    self { RewardRepository(rewardAPI: self.rewardAPI.callAsFunction()) }
  }
  
  public var rewardDataManager: Factory<RewardDataStorageProtocol> {
    self { RewardDataManager() }.singleton
  }
}
