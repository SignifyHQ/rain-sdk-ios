import Foundation

/// Ethereum transaction parameters
public struct ETHTransactionParam {
  /// Sender wallet address
  public let from: String
  
  /// Recipient contract address
  public let to: String
  
  /// Transaction value in Wei (hex string)
  public let value: String
  
  /// Transaction calldata (hex string)
  public let data: String
  
  /// Initialize transaction parameters
  /// - Parameters:
  ///   - from: Sender wallet address
  ///   - to: Recipient contract address
  ///   - value: Transaction value in Wei (hex string)
  ///   - data: Transaction calldata (hex string)
  public init(
    from: String,
    to: String,
    value: String,
    data: String
  ) {
    self.from = from
    self.to = to
    self.value = value
    self.data = data
  }
}
