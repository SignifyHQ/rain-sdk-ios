import Foundation

public protocol TransactionListEntity {
  var total: Int { get }
  var data: [TransactionEntity] { get }
}

public protocol TransactionEntity {
  var id: String { get }
  var accountId: String { get }
  var title: String? { get }
  var description: String? { get }
  var amount: Int? { get }
  var currentBalance: Int? { get }
  var type: String? { get }
  var status: String? { get }
  var completedAt: String? { get }
  var createdAt: String? { get }
  var updatedAt: String? { get }
}
