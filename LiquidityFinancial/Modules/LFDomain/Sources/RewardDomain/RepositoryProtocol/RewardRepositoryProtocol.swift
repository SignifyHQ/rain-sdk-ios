import Foundation

public protocol RewardRepositoryProtocol {
  func selectRewardType(body: [String: Any]) async throws -> SelectRewardEntity
  func getDonationCategories(limit: Int, offset: Int) async throws -> RewardCategoriesListEntity
  func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> CategoriesFundraisersListEntity
  func getFundraisersDetail(fundraiserID: String) async throws -> any FundraisersDetailEntity
  func selectFundraiser(body: [String: Any]) async throws -> SelectFundraiserEntity
  func setRoundUpDonation(body: [String: Any]) async throws -> RoundUpDonationEntity
  func getContributionList(limit: Int, offset: Int) async throws -> ContributionListEntity
  func getContribution(contributionID: String) async throws -> ContributionEntity
  func getCategoriesTrending() async throws -> CategoriesFundraisersListEntity
  func postDonationsSuggest(name: String) async throws -> Bool
  func getUserDonationSummary() async throws -> any UserDonationSummaryEntity
}
