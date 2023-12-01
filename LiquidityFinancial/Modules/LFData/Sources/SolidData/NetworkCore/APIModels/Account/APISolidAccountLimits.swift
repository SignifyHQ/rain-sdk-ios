import Foundation
import SolidDomain

// MARK: - WelcomeElement
public struct APISolidAccountLimits: Codable, SolidAccountLimitsEntity {
  public var depositCardDaily: Double? {
    deposit.debitCard?.daily
  }
  
  public var depositCardMonthly: Double? {
    deposit.debitCard?.monthly
  }
  
  public var depositAchDaily: Double? {
    deposit.ach?.daily
  }
  
  public var depositAchMonthly: Double? {
    deposit.ach?.monthly
  }
  
  public var depositTotalDaily: Double? {
    deposit.daily
  }
  
  public var depositTotalMonthly: Double? {
    deposit.monthly
  }
  
  public var withdrawalCardDaily: Double? {
    withdrawal.debitCard?.daily
  }
  
  public var withdrawalCardMonthly: Double? {
    withdrawal.debitCard?.monthly
  }
  
  public var withdrawalAchDaily: Double? {
    withdrawal.ach?.daily
  }
  
  public var withdrawalAchMonthly: Double? {
    withdrawal.ach?.monthly
  }
  
  public var withdrawalTotalDaily: Double? {
    withdrawal.daily
  }
  
  public var withdrawalTotalMonthly: Double? {
    withdrawal.monthly
  }
  
  public let deposit: Deposit
  public let withdrawal: Withdrawal
}

public extension APISolidAccountLimits {
  // MARK: - Deposit
  struct Deposit: Codable {
    public let daily, monthly: Double?
    public let ach: AchValue?
    public let card, debitCard: CardValue?
  }

  // MARK: - Ach
  struct AchValue: Codable {
    public let daily, monthly: Double?
  }
  
  // MARK: - Card
  struct CardValue: Codable {
    public let daily, monthly: Double?
  }

  // MARK: - Withdrawal
  struct Withdrawal: Codable {
    public let daily, monthly: Double?
    public let ach: AchValue?
    public let debitCard: CardValue?
  }
}
