import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager

public enum RewardRoute {
  case selectRewardType(body: [String: Any])
  case getDonationCategories(limit: Int, offset: Int)
  case getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int)
  case getFundraisersDetail(fundraiserID: String)
  case selectFundraiser(body: [String: Any])
  case setRoundUpDonation(body: [String: Any])
  case getContributionList(limit: Int, offset: Int)
  case getContribution(contributionID: String)
  case getCategoriesTrending
}

extension RewardRoute: LFRoute {

  public var path: String {
    switch self {
    case .selectRewardType:
      return "v1/user/reward-type"
    case .getDonationCategories:
      return "/v1/donations/categories"
    case .getCategoriesFundraisers(let categoryID, _, _):
      return "/v1/donations/categories/\(categoryID)/fundraisers"
    case .getFundraisersDetail(let fundraiserID):
      return "/v1/donations/fundraisers/\(fundraiserID)"
    case .selectFundraiser:
      return "v1/user/selected-fundraiser"
    case .setRoundUpDonation:
      return "v1/user/round-up-donation"
    case .getContributionList:
      return "/v1/donations/contributions"
    case .getContribution(let contributionID):
      return "/v1/donations/contributions/\(contributionID)"
    case .getCategoriesTrending:
      return "/v1/donations/categories-trending/fundraisers"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .selectRewardType: return .POST
    case .getDonationCategories: return .GET
    case .getCategoriesFundraisers: return .GET
    case .getFundraisersDetail: return .GET
    case .getContributionList: return .GET
    case .getContribution: return .GET
    case .getCategoriesTrending: return .GET
    case .selectFundraiser, .setRoundUpDonation: return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    let base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
    switch self {
    case .selectRewardType, .getDonationCategories, .getCategoriesFundraisers, .getContribution, .getCategoriesTrending,
        .getFundraisersDetail, .selectFundraiser, .setRoundUpDonation, .getContributionList:
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .selectRewardType(let body):
      return body
    case .selectFundraiser(let body):
      return body
    case .setRoundUpDonation(let body):
      return body
    case let .getDonationCategories(limit, offset):
      return [
        "limit": String(limit),
        "offset": String(offset)
      ]
    case let .getCategoriesFundraisers(_, limit, offset):
      return [
        "limit": String(limit),
        "offset": String(offset)
      ]
    case let .getContributionList(limit, offset):
      return [
        "limit": String(limit),
        "offset": String(offset)
      ]
    case .getFundraisersDetail, .getContribution, .getCategoriesTrending:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .selectRewardType, .selectFundraiser, .setRoundUpDonation:
      return .json
    case .getDonationCategories, .getCategoriesFundraisers, .getContributionList:
      return .url
    case .getFundraisersDetail, .getContribution, .getCategoriesTrending:
      return nil
    }
  }
  
}
