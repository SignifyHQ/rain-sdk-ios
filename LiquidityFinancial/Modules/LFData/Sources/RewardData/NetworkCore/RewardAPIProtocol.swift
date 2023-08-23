import Foundation
import NetworkUtilities
import LFUtilities
import AccountData

public protocol RewardAPIProtocol {
  func selectRewardType(body: [String: Any]) async throws -> APIUser
  func getDonationCategories(limit: Int, offset: Int) async throws -> APIRewardCategoriesList
  func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> APICategoriesFundraisersList
  func getFundraisersDetail(fundraiserID: String) async throws -> APIFundraisersDetail
  func selectFundraiser(body: [String: Any]) async throws -> APISelectFundraiser
  func setRoundUpDonation(body: [String: Any]) async throws -> APIRoundUpDonation
  func getContributionList(limit: Int, offset: Int) async throws -> APIContributionList
  func getContribution(contributionID: String) async throws -> APIContribution
  func getCategoriesTrending() async throws -> APICategoriesFundraisersList
}
