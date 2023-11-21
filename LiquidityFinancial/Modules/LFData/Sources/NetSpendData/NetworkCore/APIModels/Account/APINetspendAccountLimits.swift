import Foundation
import NetspendDomain

// MARK: - APINetspendAccountLimits
public struct APINetspendAccountLimits: Codable, NSAccountLimitsEntity {
  public var spendingLimits: SpendingLimits
  public var withdrawalLimits: WithdrawalLimits
  public var depositLimits: DepositLimits
}

// MARK: - DepositLimits
public struct DepositLimits: Codable, DepositLimitsEntity {
  public var sendToCardLimits: [NetspendLimitValue]
  public var externalCardLimits: [NetspendLimitValue]
  public var externalBankLimits: [NetspendLimitValue]
  
  public init(sendToCardLimits: [NetspendLimitValue] = [], externalCardLimits: [NetspendLimitValue] = [], externalBankLimits: [NetspendLimitValue] = []) {
    self.sendToCardLimits = sendToCardLimits
    self.externalCardLimits = externalCardLimits
    self.externalBankLimits = externalBankLimits
  }
}

// MARK: - SpendingLimits
public struct SpendingLimits: Codable, SpendingLimitsEntity {
  public var financialInstitutionLimits: [NetspendLimitValue]
  public var spendingLimits: [NetspendLimitValue]
  
  public init(financialInstitutionLimits: [NetspendLimitValue] = [], spendingLimits: [NetspendLimitValue] = []) {
    self.financialInstitutionLimits = financialInstitutionLimits
    self.spendingLimits = spendingLimits
  }
}

// MARK: - WithdrawalLimits
public struct WithdrawalLimits: Codable, WithdrawalLimitsEntity {
  public var externalCardLimits: [NetspendLimitValue]
  public var externalBankLimits: [NetspendLimitValue]
  
  public init(externalCardLimits: [NetspendLimitValue] = [], externalBankLimits: [NetspendLimitValue] = []) {
    self.externalCardLimits = externalCardLimits
    self.externalBankLimits = externalBankLimits
  }
}

// MARK: - Limit
public struct NetspendLimitValue: Codable, LimitValueEntity {
  public var interval: String
  public var amount: Int
  
  public init(interval: String, amount: Int) {
    self.interval = interval
    self.amount = amount
  }
}
