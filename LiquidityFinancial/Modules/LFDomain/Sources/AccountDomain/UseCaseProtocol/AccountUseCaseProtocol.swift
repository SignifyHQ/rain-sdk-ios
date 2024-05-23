import Foundation

public protocol AccountUseCaseProtocol {
  func logout() async throws -> Bool
  func getReferralCampaign() async throws -> ReferralCampaignEntity
  func addToWaitList(waitList: String) async throws -> Bool
  func getUserRewards() async throws -> [UserRewardsEntity]
  func getFeatureConfig() async throws -> AccountFeatureConfigEntity
}
