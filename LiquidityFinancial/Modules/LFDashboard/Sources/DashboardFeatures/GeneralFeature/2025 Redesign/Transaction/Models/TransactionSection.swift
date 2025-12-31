import Foundation

struct TransactionSection: Identifiable, Equatable {
  let id = UUID()
  let month: String
  var items: [TransactionModel]
  var isExpanded: Bool = false
}
