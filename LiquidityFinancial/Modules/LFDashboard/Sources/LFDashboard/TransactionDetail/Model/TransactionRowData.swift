// MARK: - TransactionRowData

struct TransactionRowData: Hashable {
  let title: String
  let value: String?
  let markValue: String?
  let shouldUppercase: Bool
  
  init(title: String, markValue: String? = nil, value: String? = nil, shouldUppercase: Bool = true) {
    self.title = title
    self.value = value
    self.markValue = markValue
    self.shouldUppercase = shouldUppercase
  }
}
