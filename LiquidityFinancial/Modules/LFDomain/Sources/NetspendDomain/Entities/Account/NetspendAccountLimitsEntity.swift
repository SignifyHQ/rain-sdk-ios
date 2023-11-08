import Foundation

public protocol NSAccountLimitsEntity {
  associatedtype SpendingLimits: SpendingLimitsEntity
  associatedtype WithdrawalLimits: WithdrawalLimitsEntity
  associatedtype DepositLimits: DepositLimitsEntity
  var spendingLimits: SpendingLimits { get }
  var withdrawalLimits: WithdrawalLimits { get }
  var depositLimits: DepositLimits { get }
}

public protocol SpendingLimitsEntity {
  associatedtype NetspendLimitValue: LimitValueEntity
  var spendingLimits: [NetspendLimitValue] { get }
  var financialInstitutionLimits: [NetspendLimitValue] { get }
}

public protocol WithdrawalLimitsEntity {
  associatedtype NetspendLimitValue: LimitValueEntity
  var externalCardLimits: [NetspendLimitValue] { get }
  var externalBankLimits: [NetspendLimitValue] { get }
}

public protocol DepositLimitsEntity {
  associatedtype NetspendLimitValue: LimitValueEntity
  var sendToCardLimits: [NetspendLimitValue] { get }
  var externalCardLimits: [NetspendLimitValue] { get }
  var externalBankLimits: [NetspendLimitValue] { get }
}

public protocol LimitValueEntity {
  var interval: String { get }
  var amount: Int { get }
}
