public struct WithdrawAssetAddresses {
  public let contractAddress: String
  public let proxyAddress: String
  public let recipientAddress: String
  public let tokenAddress: String
  
  public init(
    contractAddress: String,
    proxyAddress: String,
    recipientAddress: String,
    tokenAddress: String
  ) {
    self.contractAddress = contractAddress
    self.proxyAddress = proxyAddress
    self.recipientAddress = recipientAddress
    self.tokenAddress = tokenAddress
  }
}
