import Foundation

public struct DisputeTransactionParameters {
  public let id: String
  public let passcode: String
  public let onClose: (() -> Void)
}
