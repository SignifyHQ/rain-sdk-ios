import Foundation

public protocol UserRewardsEntity {
  var name: String? { get }
  var returnRate: Double? { get }
  var specialPromo: Bool? { get }
}
