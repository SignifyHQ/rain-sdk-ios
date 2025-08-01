import Foundation
import MeshDomain
import NetworkUtilities

public struct MeshBalance: MeshBalanceEntity, Parameterable {
  public var symbol: String
  public var buyingPower: Decimal
  public var cryptoBuyingPower: Decimal
  public var cash: Decimal
}
