import Foundation

public struct TransactionInformation: Hashable {
  let title: String
  let value: String
  let markValue: String?
  
  public init(title: String, value: String, markValue: String? = nil) {
    self.title = title
    self.value = value
    self.markValue = markValue
  }
}
