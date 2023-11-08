import Foundation

@testable import SolidData

struct MockAPISolidAccountLimits {
  static var deposit = APISolidAccountLimits.Deposit(daily: 0, monthly: 0, ach: APISolidAccountLimits.Ach(daily: 0, monthly: 0), card: APISolidAccountLimits.Ach(daily: 0, monthly: 0), debitCard: APISolidAccountLimits.Ach(daily: 0, monthly: 0))
  static var withdrawal = APISolidAccountLimits.Withdrawal(daily: 0, monthly: 0, ach: APISolidAccountLimits.Ach(daily: 0, monthly: 0), debitCard: APISolidAccountLimits.Ach(daily: 0, monthly: 0))
  static var spending = APISolidAccountLimits.Spending(limitAmount: "", limitInterval: "", availableLimit: "")
  static var mockData = APISolidAccountLimits(
    deposit: deposit,
    withdrawal: withdrawal,
    spending: spending
  )
}
