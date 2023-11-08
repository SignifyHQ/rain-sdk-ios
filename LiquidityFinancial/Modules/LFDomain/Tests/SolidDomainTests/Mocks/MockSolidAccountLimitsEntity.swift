import Foundation
import SolidDomain

struct MockSolidAccountLimitsEntity: SolidAccountLimitsEntity {
  var depositCardDaily: String?
  var depositCardMonthly: String?
  var depositAchDaily: String?
  var depositAchMonthly: String?
  var depositTotalDaily: String
  var depositTotalMonthly: String
  var withdrawalCardDaily: String?
  var withdrawalCardMonthly: String?
  var withdrawalAchDaily: String?
  var withdrawalAchMonthly: String?
  var withdrawalTotalDaily: String
  var withdrawalTotalMonthly: String
  var spendingAmount: String?
  var spendingLimitInterval: SolidDomain.SolidSpendingLimitInterval?
  
  init(depositCardDaily: String? = nil, depositCardMonthly: String? = nil, depositAchDaily: String? = nil, depositAchMonthly: String? = nil, depositTotalDaily: String, depositTotalMonthly: String, withdrawalCardDaily: String? = nil, withdrawalCardMonthly: String? = nil, withdrawalAchDaily: String? = nil, withdrawalAchMonthly: String? = nil, withdrawalTotalDaily: String, withdrawalTotalMonthly: String, spendingAmount: String? = nil, spendingLimitInterval: SolidDomain.SolidSpendingLimitInterval? = nil) {
    self.depositCardDaily = depositCardDaily
    self.depositCardMonthly = depositCardMonthly
    self.depositAchDaily = depositAchDaily
    self.depositAchMonthly = depositAchMonthly
    self.depositTotalDaily = depositTotalDaily
    self.depositTotalMonthly = depositTotalMonthly
    self.withdrawalCardDaily = withdrawalCardDaily
    self.withdrawalCardMonthly = withdrawalCardMonthly
    self.withdrawalAchDaily = withdrawalAchDaily
    self.withdrawalAchMonthly = withdrawalAchMonthly
    self.withdrawalTotalDaily = withdrawalTotalDaily
    self.withdrawalTotalMonthly = withdrawalTotalMonthly
    self.spendingAmount = spendingAmount
    self.spendingLimitInterval = spendingLimitInterval
  }
  
  static var mockData = MockSolidAccountLimitsEntity(depositTotalDaily: "10.00", depositTotalMonthly: "10.00", withdrawalTotalDaily: "10.00", withdrawalTotalMonthly: "10.00")
}
