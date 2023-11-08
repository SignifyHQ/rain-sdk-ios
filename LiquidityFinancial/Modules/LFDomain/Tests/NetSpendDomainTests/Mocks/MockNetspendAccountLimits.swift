import Foundation
import NetspendDomain

// MARK: - APINetspendAccountLimits
struct MockNetspendAccountLimits: Codable, NSAccountLimitsEntity {
  var spendingLimits: SpendingLimits
  var withdrawalLimits: WithdrawalLimits
  var depositLimits: DepositLimits
  
  static var mock = MockNetspendAccountLimits(
    spendingLimits: SpendingLimits(),
    withdrawalLimits: WithdrawalLimits(),
    depositLimits: DepositLimits()
  )
}

// MARK: - DepositLimits
struct DepositLimits: Codable, DepositLimitsEntity {
  var sendToCardLimits: [NetspendLimitValue]
  var externalCardLimits: [NetspendLimitValue]
  var externalBankLimits: [NetspendLimitValue]
  
  init(sendToCardLimits: [NetspendLimitValue] = [], externalCardLimits: [NetspendLimitValue] = [], externalBankLimits: [NetspendLimitValue] = []) {
    self.sendToCardLimits = sendToCardLimits
    self.externalCardLimits = externalCardLimits
    self.externalBankLimits = externalBankLimits
  }
}

// MARK: - SpendingLimits
struct SpendingLimits: Codable, SpendingLimitsEntity {
  var financialInstitutionLimits: [NetspendLimitValue]
  var spendingLimits: [NetspendLimitValue]
  
  init(financialInstitutionLimits: [NetspendLimitValue] = [], spendingLimits: [NetspendLimitValue] = []) {
    self.financialInstitutionLimits = financialInstitutionLimits
    self.spendingLimits = spendingLimits
  }
}

// MARK: - WithdrawalLimits
struct WithdrawalLimits: Codable, WithdrawalLimitsEntity {
  var externalCardLimits: [NetspendLimitValue]
  var externalBankLimits: [NetspendLimitValue]
  
  init(externalCardLimits: [NetspendLimitValue] = [], externalBankLimits: [NetspendLimitValue] = []) {
    self.externalCardLimits = externalCardLimits
    self.externalBankLimits = externalBankLimits
  }
}

// MARK: - Limit
struct NetspendLimitValue: Codable, LimitValueEntity {
  var interval: String
  var amount: Int
  
  init(interval: String, amount: Int) {
    self.interval = interval
    self.amount = amount
  }
}
