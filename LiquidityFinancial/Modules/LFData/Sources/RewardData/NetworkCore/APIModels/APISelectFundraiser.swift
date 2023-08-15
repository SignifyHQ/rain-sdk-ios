import Foundation
import RewardDomain

public struct APISelectFundraiser: Decodable, SelectFundraiserEntity {
  public let userRewardType: String?
  public let userSelectedFundraiserId: String?
  public let userRoundUpEnabled: Bool?
}
