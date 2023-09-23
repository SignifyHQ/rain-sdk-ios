import Foundation

public protocol TransferLimitConfigEntity {
  var userId: String? { get }
  var productId: String? { get }
  var period: String? { get }
  var transferType: String? { get }
  var priority: Int { get }
  var amount: Double { get }
  var transferredAmount: Double? { get }
  var type: String { get }
  var createdAt: String? { get }
  var updatedAt: String? { get }
}
