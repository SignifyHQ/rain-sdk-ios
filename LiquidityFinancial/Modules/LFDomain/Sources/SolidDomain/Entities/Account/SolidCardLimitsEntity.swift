import Foundation

public protocol SolidCardLimitsEntity {
  var solidCardId: String { get }
  var limitAmount: Int? { get }
  var limitInterval: String? { get }
  var availableLimit: Int? { get }
  var platformPerTransactionLimit: Int? { get }
}
