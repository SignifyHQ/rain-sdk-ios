import Foundation
import RewardDomain
import Combine

public protocol RewardDataStorageProtocol {
  var selectRewardChangedEvent: CurrentValueSubject<SelectRewardTypeEntity, Never> { get }
  var currentSelectReward: SelectRewardTypeEntity? { get }
  var rewardCategories: RewardCategoriesListEntity? { get }
  var fundraisers: CategoriesFundraisersListEntity? { get }
  var fundraisersDetail: (any FundraisersDetailEntity)? { get }
  var selectedFundraiserID: String? { get }
  var roundUpDonation: Bool? { get }
  
  func update(currentSelectReward: SelectRewardTypeEntity)
  func update(rewardCategories: RewardCategoriesListEntity)
  func update(fundraisers: CategoriesFundraisersListEntity)
  func update(selectedFundraiserID: String)
  func update(roundUpDonation: Bool)
  func update(fundraisersDetail: any FundraisersDetailEntity)
}

public final class RewardDataManager: RewardDataStorageProtocol {
  public let selectRewardChangedEvent: CurrentValueSubject<SelectRewardTypeEntity, Never>
    
  public private(set) var currentSelectReward: SelectRewardTypeEntity?
  public private(set) var rewardCategories: RewardCategoriesListEntity?
  public private(set) var fundraisers: CategoriesFundraisersListEntity?
  public private(set) var fundraisersDetail: (any FundraisersDetailEntity)?
  public private(set) var selectedFundraiserID: String?
  public private(set) var roundUpDonation: Bool?
  
  init() {
    self.selectRewardChangedEvent = CurrentValueSubject<SelectRewardTypeEntity, Never>(APIRewardType.none)
  }
  
  public func update(currentSelectReward: SelectRewardTypeEntity) {
    self.currentSelectReward = currentSelectReward
    selectRewardChangedEvent.value = currentSelectReward
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
  
  public func update(fundraisersDetail: any FundraisersDetailEntity) {
    self.fundraisersDetail = fundraisersDetail
  }
  
  func clear() {
    currentSelectReward = nil
    rewardCategories = nil
    fundraisers = nil
    selectedFundraiserID = nil
    roundUpDonation = nil
    fundraisersDetail = nil
  }
}
