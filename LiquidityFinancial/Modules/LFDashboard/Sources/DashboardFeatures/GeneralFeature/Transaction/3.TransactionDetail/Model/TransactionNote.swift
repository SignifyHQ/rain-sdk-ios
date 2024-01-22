import Foundation

public struct TransactionNote {
  public let title: String?
  public let message: String?
  
  public init(title: String?, message: String?) {
    self.title = title
    self.message = message
  }
}
