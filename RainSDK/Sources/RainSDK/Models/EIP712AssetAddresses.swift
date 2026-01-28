import Foundation

/// Address parameters for EIP-712 message building
public struct EIP712AssetAddresses {
  public let proxyAddress: String
  public let recipientAddress: String
  public let tokenAddress: String
  
  public init(
    proxyAddress: String,
    recipientAddress: String,
    tokenAddress: String
  ) {
    self.proxyAddress = proxyAddress
    self.recipientAddress = recipientAddress
    self.tokenAddress = tokenAddress
  }
  
  /// Convert to WithdrawAssetAddresses for use with buildWithdrawTransactionData
  /// - Parameter contractAddress: The contract address to include
  internal func toWithdrawAssetAddresses(contractAddress: String) -> WithdrawAssetAddresses {
    return WithdrawAssetAddresses(
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
  }
}
