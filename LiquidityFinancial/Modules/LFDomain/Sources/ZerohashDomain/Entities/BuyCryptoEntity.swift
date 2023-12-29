import Foundation

public protocol BuyCryptoEntity {
  var id: String? { get set }
  var accountID: String? { get set }
  var title: String? { get set }
  var currency: String? { get set }
  var description: String? { get set }
  var amount: Double? { get set }
  var currentBalance: Double? { get set }
  var fee: Double? { get set }
  var type: String? { get set }
  var status: String? { get set }
  var completedAt: String? { get set }
  var createdAt: String? { get set }
  var updatedAt: String? { get set }
}
