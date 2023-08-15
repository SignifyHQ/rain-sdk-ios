import Foundation
import RewardDomain
import LFUtilities

public class RewardRepository: RewardRepositoryProtocol {

  private let rewardAPI: RewardAPIProtocol
  
  public init(rewardAPI: RewardAPIProtocol) {
    self.rewardAPI = rewardAPI
  }

  public func selectRewardType(body: [String: Any]) async throws -> SelectRewardEntity {
    let apiUser = try await self.rewardAPI.selectRewardType(body: body)
    let model = APISelectReward(rewardType: APIRewardType(rawValue: apiUser.userRewardType ?? ""))
    return model
  }
 
  public func getDonationCategories(limit: Int, offset: Int) async throws -> RewardCategoriesListEntity {
    return try await self.rewardAPI.getDonationCategories(limit: limit, offset: offset)
  }
  
  public func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> CategoriesFundraisersListEntity {
    return try await self.rewardAPI.getCategoriesFundraisers(categoryID: categoryID, limit: limit, offset: offset)
  }

  public func getFundraisersDetail(fundraiserID: String) async throws -> any FundraisersDetailEntity {
    return try await self.rewardAPI.getFundraisersDetail(fundraiserID: fundraiserID)
  }
  
  public func selectFundraiser(body: [String: Any]) async throws -> SelectFundraiserEntity {
    return try await self.rewardAPI.selectFundraiser(body: body)
  }
  
  public func setRoundUpDonation(body: [String: Any]) async throws -> RoundUpDonationEntity {
    return try await self.rewardAPI.setRoundUpDonation(body: body)
  }
}
