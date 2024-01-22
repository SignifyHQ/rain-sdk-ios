import Foundation
import SolidDomain
import LFLocalizable

struct AccountLimitsUIModel {
  var deposit: AccountDepositLimitsUIModel
  var withdrawal: AccountWithdrawalLimitsUIModel
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    deposit = AccountDepositLimitsUIModel(accountLimitsEntity: accountLimitsEntity)
    withdrawal = AccountWithdrawalLimitsUIModel(accountLimitsEntity: accountLimitsEntity)
  }
  
  init() {
    deposit = AccountDepositLimitsUIModel()
    withdrawal = AccountWithdrawalLimitsUIModel()
  }
}

struct AccountDepositLimitsUIModel {
  var depositCardDaily: Double?
  var depositCardMonthly: Double?
  var depositAchDaily: Double?
  var depositAchMonthly: Double?
  var depositTotalDaily: Double?
  var depositTotalMonthly: Double?
  
  var depositTotalEmpty: Bool {
    depositTotalDaily == nil
  }
  
  var depositCardEmpty: Bool {
    depositCardDaily == nil && depositCardMonthly == nil
  }
  
  var depositAcHEmpty: Bool {
    depositAchDaily == nil && depositAchMonthly == nil
  }
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    self.depositAchDaily = accountLimitsEntity.depositAchDaily
    self.depositAchMonthly = accountLimitsEntity.depositAchMonthly
    self.depositCardDaily = accountLimitsEntity.depositCardDaily
    self.depositCardMonthly = accountLimitsEntity.depositCardMonthly
    self.depositTotalDaily = accountLimitsEntity.depositTotalDaily
    self.depositTotalMonthly = accountLimitsEntity.depositTotalMonthly
  }
  
  init() {}
}

struct AccountWithdrawalLimitsUIModel {
  var withdrawalCardDaily: Double?
  var withdrawalCardMonthly: Double?
  var withdrawalAchDaily: Double?
  var withdrawalAchMonthly: Double?
  var withdrawalTotalDaily: Double?
  var withdrawalTotalMonthly: Double?
  
  var withdrawalTotalEmpty: Bool {
    withdrawalTotalDaily == nil
  }
  
  var withdrawalCardEmpty: Bool {
    withdrawalCardDaily == nil && withdrawalCardMonthly == nil
  }
  
  var withdrawalAcHEmpty: Bool {
    withdrawalAchDaily == nil && withdrawalAchMonthly == nil
  }
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    self.withdrawalAchDaily = accountLimitsEntity.withdrawalAchDaily
    self.withdrawalAchMonthly = accountLimitsEntity.withdrawalAchMonthly
    self.withdrawalCardDaily = accountLimitsEntity.withdrawalCardDaily
    self.withdrawalCardMonthly = accountLimitsEntity.withdrawalCardMonthly
    self.withdrawalTotalDaily = accountLimitsEntity.withdrawalTotalDaily
    self.withdrawalTotalMonthly = accountLimitsEntity.withdrawalTotalMonthly
  }
  
  init() {}
}

extension String {
  var toDouble: Double? {
    Double(self)
  }
}
