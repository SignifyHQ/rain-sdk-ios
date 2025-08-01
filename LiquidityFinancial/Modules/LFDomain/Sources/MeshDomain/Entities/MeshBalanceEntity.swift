import Foundation

// sourcery: AutoMockable
public protocol MeshBalanceEntity {
  var symbol: String { get }
  var buyingPower: Decimal { get }
  var cryptoBuyingPower: Decimal { get }
  var cash: Decimal { get }
}
