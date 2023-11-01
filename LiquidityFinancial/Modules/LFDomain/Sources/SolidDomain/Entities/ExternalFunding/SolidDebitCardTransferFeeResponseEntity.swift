import Foundation

// sourcery: AutoMockable
public protocol SolidDebitCardTransferFeeResponseEntity {
  var fee: Double { get }
  var amount: Double { get }
  var total: Double { get }
}
