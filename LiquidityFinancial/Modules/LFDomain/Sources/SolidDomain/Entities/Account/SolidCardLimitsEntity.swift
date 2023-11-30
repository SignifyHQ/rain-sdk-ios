import Foundation

public protocol SolidCardLimitsEntity {
  var solidCardId: String { get }
  var limitAmount: Double? { get }
  var limitInterval: String? { get }
  var availableLimit: Double? { get }
  var platformPerTransactionLimit: Double? { get }
}
