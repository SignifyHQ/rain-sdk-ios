import Foundation

public protocol SolidAccountLimitsEntity {
  var depositCardDaily: Double? { get }
  var depositCardMonthly: Double? { get }
  var depositAchDaily: Double? { get }
  var depositAchMonthly: Double? { get }
  var depositTotalDaily: Double? { get }
  var depositTotalMonthly: Double? { get }
  
  var withdrawalCardDaily: Double? { get }
  var withdrawalCardMonthly: Double? { get }
  var withdrawalAchDaily: Double? { get }
  var withdrawalAchMonthly: Double? { get }
  var withdrawalTotalDaily: Double? { get }
  var withdrawalTotalMonthly: Double? { get }
}

public enum SolidSpendingLimitInterval: String {
  case daily, weekly, monthly, yearly, allTime, perTransaction
}
