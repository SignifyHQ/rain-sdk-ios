import Foundation

protocol RewardUseCaseProtocol {
  func selectReward(body: [String: Any]) async throws -> SelectRewardEntity
  func getDonationCategories(limit: Int, offset: Int) async throws -> RewardCategoriesListEntity
  func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> CategoriesFundraisersListEntity
  func getFundraisersDetail(fundraiserID: String) async throws -> any FundraisersDetailEntity
  func selectFundraiser(body: [String: Any]) async throws -> SelectFundraiserEntity
  func setRoundUpDonation(body: [String: Any]) async throws -> RoundUpDonationEntity
}
