import Foundation
import AccountDomain

public struct APIUserRewards: Decodable, UserRewardsEntity, Identifiable, Equatable {
  public var id: String {
    UUID().uuidString
  }
  public let name: String?
  public let returnRate: Double?
  public let specialPromo: Bool?
}
