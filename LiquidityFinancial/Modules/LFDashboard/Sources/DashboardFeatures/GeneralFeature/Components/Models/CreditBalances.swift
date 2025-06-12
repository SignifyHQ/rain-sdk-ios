import Foundation
import RainDomain

public struct CreditBalances {
  public let spendingPower: Double?
  let creditLimit: Double?
  let pendingCharges: Double?
  let pendingLiquidation: Double?
  
  public init(
    rainCreditBalances: RainCreditBalanceEntity
  ) {
    spendingPower = rainCreditBalances.availableBalance
    creditLimit = rainCreditBalances.creditLimit
    pendingCharges = rainCreditBalances.pendingCharges
    pendingLiquidation = (rainCreditBalances.balanceDue ?? 0) + (rainCreditBalances.postedCharges ?? 0)
  }
  
  public init(
    spendingPower: Double? = nil,
    creditLimit: Double? = nil,
    pendingCharges: Double? = nil,
    pendingLiquidation: Double? = nil
  ) {
    self.spendingPower = pendingCharges
    self.creditLimit = creditLimit
    self.pendingCharges = pendingCharges
    self.pendingLiquidation = pendingLiquidation
  }
  
  public var spendingPowerFormatted: String {
    spendingPower?.formattedUSDAmount() ?? "N/A"
  }
  
  public var creditLimitFormatted: String {
    creditLimit?.formattedUSDAmount() ?? "N/A"
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
