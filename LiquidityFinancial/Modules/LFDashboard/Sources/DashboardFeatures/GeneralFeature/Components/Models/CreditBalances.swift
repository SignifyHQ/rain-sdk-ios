import Foundation
import RainDomain

public struct CreditBalances {
  let spendingPower: Double?
  let pendingCharges: Double?
  let pendingLiquidation: Double?
  
  public init(
    rainCreditBalances: RainCreditBalanceEntity
  ) {
    spendingPower = rainCreditBalances.availableBalance
    pendingCharges = rainCreditBalances.pendingCharges
    pendingLiquidation = rainCreditBalances.balanceDue
  }
  
  public init(
    spendingPower: Double? = nil,
    pendingCharges: Double? = nil,
    pendingLiquidation: Double? = nil
  ) {
    self.spendingPower = pendingCharges
    self.pendingCharges = pendingCharges
    self.pendingLiquidation = pendingLiquidation
  }
  
  public var spendingPowerFormatted: String {
    spendingPower?.formattedUSDAmount() ?? "N/A"
  }
  
  public var pendingChargesFormatted: String {
    guard let pendingCharges
    else {
      return "N/A"
    }
    
    return "-\(pendingCharges.formattedUSDAmount())"
  }
  
  public var pendingLiquidationFormatted: String {
    guard let pendingLiquidation
    else {
      return "N/A"
    }
    
    return "-\(pendingLiquidation.formattedUSDAmount())"
  }
}
