import Foundation

public protocol SolidAccountLimitsEntity {
  var depositCardDaily: String? { get }
  var depositCardMonthly: String? { get }
  var depositAchDaily: String? { get }
  var depositAchMonthly: String? { get }
  var depositTotalDaily: String { get }
  var depositTotalMonthly: String { get }
  
  var withdrawalCardDaily: String? { get }
  var withdrawalCardMonthly: String? { get }
  var withdrawalAchDaily: String? { get }
  var withdrawalAchMonthly: String? { get }
  var withdrawalTotalDaily: String { get }
  var withdrawalTotalMonthly: String { get }
  
  var spendingAmount: String? { get }
  var spendingLimitInterval: SolidSpendingLimitInterval? { get }
}

public enum SolidSpendingLimitInterval: String {
  case daily, weekly, monthly, yearly, allTime, perTransaction
}
