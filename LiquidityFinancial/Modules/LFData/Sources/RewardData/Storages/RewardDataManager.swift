import Foundation
import RewardDomain

public protocol RewardDataStorageProtocol {
  var currentSelectReward: SelectRewardTypeEntity? { get }
  var rewardCategories: RewardCategoriesListEntity? { get }
  var fundraisers: CategoriesFundraisersListEntity? { get }
  var selectedFundraiserID: String? { get }
  var roundUpDonation: Bool? { get }
  
  func update(currentSelectReward: SelectRewardTypeEntity)
  func update(rewardCategories: RewardCategoriesListEntity)
  func update(fundraisers: CategoriesFundraisersListEntity)
  func update(selectedFundraiserID: String)
  func update(roundUpDonation: Bool)
}

public final class RewardDataManager: RewardDataStorageProtocol {
  public private(set) var currentSelectReward: SelectRewardTypeEntity?
  public private(set) var rewardCategories: RewardCategoriesListEntity?
  public private(set) var fundraisers: CategoriesFundraisersListEntity?
  public private(set) var selectedFundraiserID: String?
  public private(set) var roundUpDonation: Bool?
  
  public func update(currentSelectReward: SelectRewardTypeEntity) {
    self.currentSelectReward = currentSelectReward
  }
  
  public func update(rewardCategories: RewardCategoriesListEntity) {
    self.rewardCategories = rewardCategories
  }
  
  public func update(fundraisers: CategoriesFundraisersListEntity) {
    self.fundraisers = fundraisers
  }
  
  public func update(selectedFundraiserID: String) {
    self.selectedFundraiserID = selectedFundraiserID
  }
  
  public func update(roundUpDonation: Bool) {
    self.roundUpDonation = roundUpDonation
  }
  
  func clear() {
    currentSelectReward = nil
    rewardCategories = nil
    fundraisers = nil
    selectedFundraiserID = nil
    roundUpDonation = nil
  }
}
