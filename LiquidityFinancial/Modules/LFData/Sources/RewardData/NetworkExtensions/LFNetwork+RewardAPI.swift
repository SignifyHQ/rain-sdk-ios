import Foundation
import DataUtilities
import LFNetwork
import LFUtilities
import AccountData

extension LFNetwork: RewardAPIProtocol where R == RewardRoute {
  public func selectRewardType(body: [String: Any]) async throws -> APIUser {
    return try await request(RewardRoute.selectRewardType(body: body), target: APIUser.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getDonationCategories(limit: Int, offset: Int) async throws -> APIRewardCategoriesList {
    let listModel = try await request(
      RewardRoute.getDonationCategories(limit: limit, offset: offset),
      target: APIListObject<APIRewardCategories>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return APIRewardCategoriesList(total: listModel.total, data: listModel.data)
  }
  
  public func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> APICategoriesFundraisersList {
    let listModel = try await request(
      RewardRoute.getCategoriesFundraisers(categoryID: categoryID, limit: limit, offset: offset),
      target: APIListObject<APICategoriesFundraisers>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return APICategoriesFundraisersList(total: listModel.total, data: listModel.data)
  }
  
  public func getFundraisersDetail(fundraiserID: String) async throws -> APIFundraisersDetail {
    return try await request(
      RewardRoute.getFundraisersDetail(fundraiserID: fundraiserID),
      target: APIFundraisersDetail.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func selectFundraiser(body: [String: Any]) async throws -> APISelectFundraiser {
    return try await request(
      RewardRoute.selectFundraiser(body: body),
      target: APISelectFundraiser.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func setRoundUpDonation(body: [String: Any]) async throws -> APIRoundUpDonation {
    return try await request(
      RewardRoute.setRoundUpDonation(body: body),
      target: APIRoundUpDonation.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
