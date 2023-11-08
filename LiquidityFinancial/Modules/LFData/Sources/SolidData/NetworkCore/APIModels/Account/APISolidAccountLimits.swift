import Foundation
import SolidDomain

// MARK: - WelcomeElement
public struct APISolidAccountLimits: Codable, SolidAccountLimitsEntity {
  public var depositCardDaily: String? {
    deposit.debitCard.daily.toString
  }
  
  public var depositCardMonthly: String? {
    deposit.debitCard.monthly.toString
  }
  
  public var depositAchDaily: String? {
    deposit.ach.daily.toString
  }
  
  public var depositAchMonthly: String? {
    deposit.ach.monthly.toString
  }
  
  public var depositTotalDaily: String {
    deposit.daily.toString
  }
  
  public var depositTotalMonthly: String {
    deposit.monthly.toString
  }
  
  public var withdrawalCardDaily: String? {
    withdrawal.debitCard.daily.toString
  }
  
  public var withdrawalCardMonthly: String? {
    withdrawal.debitCard.monthly.toString
  }
  
  public var withdrawalAchDaily: String? {
    withdrawal.ach.daily.toString
  }
  
  public var withdrawalAchMonthly: String? {
    withdrawal.ach.monthly.toString
  }
  
  public var withdrawalTotalDaily: String {
    withdrawal.daily.toString
  }
  
  public var withdrawalTotalMonthly: String {
    withdrawal.monthly.toString
  }
  
  public var spendingAmount: String? {
    if let availableLimit = spending.availableLimit.toDouble, availableLimit > 0 {
      return spending.availableLimit
    }
    return spending.limitAmount
  }
  
  public var spendingLimitInterval: SolidDomain.SolidSpendingLimitInterval? {
    SolidSpendingLimitInterval(rawValue: spending.limitInterval)
  }
  
  public let deposit: Deposit
  public let withdrawal: Withdrawal
  public let spending: Spending
}

public extension APISolidAccountLimits {
  // MARK: - Deposit
  struct Deposit: Codable {
    public let daily, monthly: Int
    public let ach: Ach
    public let card, debitCard: Ach
  }

  // MARK: - Ach
  struct Ach: Codable {
    public let daily, monthly: Int
  }

  // MARK: - Spending
  struct Spending: Codable {
    public let limitAmount, limitInterval, availableLimit: String
  }

  // MARK: - Withdrawal
  struct Withdrawal: Codable {
    public let daily, monthly: Int
    public let ach, debitCard: Ach
  }
}

extension Int {
  var toString: String {
    String(self)
  }
}

extension String {
  var toDouble: Double? {
    Double(self)
  }
}
