import Foundation

// sourcery: AutoMockable
public protocol RainCreditBalanceEntity {
  var userId: String { get }
  var currency: String { get }
  var creditLimit: Double { get }
  var pendingCharges: Double? { get }
  var postedCharges: Double? { get }
  var balanceDue: Double? { get }
  var availableBalance: Double { get }
}
