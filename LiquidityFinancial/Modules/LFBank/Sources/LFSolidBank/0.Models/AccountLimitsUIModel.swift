import Foundation
import SolidDomain
import LFLocalizable

struct AccountLimitsUIModel {
  var deposit: AccountDepositLimitsUIModel
  var withdrawal: AccountWithdrawalLimitsUIModel
  var spending: AccountSpendingLimitsUIModel
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    deposit = AccountDepositLimitsUIModel(accountLimitsEntity: accountLimitsEntity)
    withdrawal = AccountWithdrawalLimitsUIModel(accountLimitsEntity: accountLimitsEntity)
    spending = AccountSpendingLimitsUIModel(accountLimitsEntity: accountLimitsEntity)
  }
  
  init() {
    deposit = AccountDepositLimitsUIModel()
    withdrawal = AccountWithdrawalLimitsUIModel()
    spending = AccountSpendingLimitsUIModel()
  }
}

struct AccountDepositLimitsUIModel {
  var depositCardDaily: String?
  var depositCardMonthly: String?
  var depositAchDaily: String?
  var depositAchMonthly: String?
  var depositTotalDaily: String
  var depositTotalMonthly: String
  
  var depositTotalEmpty: Bool {
    if (depositTotalDaily.toDouble ?? 0) <= 0 && (depositTotalMonthly.toDouble ?? 0) <= 0 {
      return true
    }
    return false
  }
  
  var depositCardEmpty: Bool {
    if (depositCardDaily?.toDouble ?? 0) <= 0 && (depositCardMonthly?.toDouble ?? 0) <= 0 {
      return true
    }
    return false
  }
  
  var depositAcHEmpty: Bool {
    if (depositAchDaily?.toDouble ?? 0) <= 0 && (depositAchMonthly?.toDouble ?? 0) <= 0 {
      return true
    }
    return false
  }
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    self.depositAchDaily = accountLimitsEntity.depositAchDaily
    self.depositAchMonthly = accountLimitsEntity.depositAchMonthly
    self.depositCardDaily = accountLimitsEntity.depositCardDaily
    self.depositCardMonthly = accountLimitsEntity.depositCardMonthly
    self.depositTotalDaily = accountLimitsEntity.depositTotalDaily
    self.depositTotalMonthly = accountLimitsEntity.depositTotalMonthly
  }
  
  init() {
    depositTotalDaily = "0"
    depositTotalMonthly = "0"
  }
}

struct AccountWithdrawalLimitsUIModel {
  var withdrawalCardDaily: String?
  var withdrawalCardMonthly: String?
  var withdrawalAchDaily: String?
  var withdrawalAchMonthly: String?
  var withdrawalTotalDaily: String
  var withdrawalTotalMonthly: String
  
  var withdrawalTotalEmpty: Bool {
    if (withdrawalTotalDaily.toDouble ?? 0) <= 0 && (withdrawalTotalMonthly.toDouble ?? 0) <= 0 {
      return true
    }
    return false
  }
  
  var withdrawalCardEmpty: Bool {
    if (withdrawalCardDaily?.toDouble ?? 0) <= 0 && (withdrawalCardMonthly?.toDouble ?? 0) <= 0 {
      return true
    }
    return false
  }
  
  var withdrawalAcHEmpty: Bool {
    if (withdrawalAchDaily?.toDouble ?? 0) <= 0 && (withdrawalAchMonthly?.toDouble ?? 0) <= 0 {
      return true
    }
    return false
  }
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    self.withdrawalAchDaily = accountLimitsEntity.withdrawalAchDaily
    self.withdrawalAchMonthly = accountLimitsEntity.withdrawalAchMonthly
    self.withdrawalCardDaily = accountLimitsEntity.withdrawalCardDaily
    self.withdrawalCardMonthly = accountLimitsEntity.withdrawalCardMonthly
    self.withdrawalTotalDaily = accountLimitsEntity.withdrawalTotalDaily
    self.withdrawalTotalMonthly = accountLimitsEntity.withdrawalTotalMonthly
  }
  
  init() {
    withdrawalTotalDaily = "0"
    withdrawalTotalMonthly = "0"
  }
  
}

struct AccountSpendingLimitsUIModel {
  var spendingAmount: String?
  var spendingLimitInterval: SolidSpendingLimitInterval?
  
  public var title: String {
    switch spendingLimitInterval {
    case .daily:
      return LFLocalizable.TransferLimit.Daily.title
    case .weekly:
      return LFLocalizable.TransferLimit.Weekly.title
    case .monthly:
      return LFLocalizable.TransferLimit.Monthly.title
    case .perTransaction:
      return LFLocalizable.TransferLimit.PerTransaction.title
    case .allTime:
      return LFLocalizable.TransferLimit.Alltime.title
    default:
      return .empty
    }
  }
  
  init(accountLimitsEntity: SolidAccountLimitsEntity) {
    spendingAmount = accountLimitsEntity.spendingAmount
    spendingLimitInterval = accountLimitsEntity.spendingLimitInterval
  }
  
  init() {
    spendingAmount = nil
    spendingLimitInterval = nil
  }
}

extension String {
  var toDouble: Double? {
    Double(self)
  }
}
