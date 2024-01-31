import Foundation

@testable import SolidData

struct MockAPISolidAccountLimits {
  static var deposit = APISolidAccountLimits.Deposit(daily: 0, monthly: 0, ach: APISolidAccountLimits.AchValue(daily: 0, monthly: 0), card: APISolidAccountLimits.CardValue(daily: 0, monthly: 0), debitCard: APISolidAccountLimits.CardValue(daily: 0, monthly: 0))
  static var withdrawal = APISolidAccountLimits.Withdrawal(daily: 0, monthly: 0, ach: APISolidAccountLimits.AchValue(daily: 0, monthly: 0), debitCard: APISolidAccountLimits.CardValue(daily: 0, monthly: 0))
  static var mockData = APISolidAccountLimits(
    deposit: deposit,
    withdrawal: withdrawal
  )
}
