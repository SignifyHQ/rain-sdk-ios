import Foundation
import Web3Core
import Web3

/// Parameters for building a withdrawal transaction
public struct WithdrawAssetParameter {
  /// Address of the collateral proxy contract
  public let proxyAddress: Web3Core.EthereumAddress
  
  /// Address of the ERC-20 token contract
  public let tokenAddress: Web3Core.EthereumAddress
  
  /// Withdrawal amount in base units (smallest denomination)
  public let amount: BigUInt
  
  /// Address of the recipient receiving the withdrawal
  public let recipientAddress: Web3Core.EthereumAddress
  
  /// Expiration timestamp (Unix timestamp)
  public let expiryAt: BigUInt
  
  /// Salt data for the user signature
  public let salt: Data
  
  /// User signature data from Rain API
  public let signature: Data
  
  /// Admin salt generated when creating admin signature
  public let adminSalt: Data
  
  /// Admin signature authorizing the withdrawal
  public let adminSignature: Data
  
  /// Initialize withdrawal asset parameters
  /// - Parameters:
  ///   - proxyAddress: Address of the collateral proxy contract
  ///   - tokenAddress: Address of the ERC-20 token contract
  ///   - amount: Withdrawal amount in base units
  ///   - recipientAddress: Address of the recipient
  ///   - expiryAt: Expiration timestamp (Unix timestamp)
  ///   - salt: Salt data for the user signature
  ///   - signature: User signature data from Rain API
  ///   - adminSalt: Admin salt generated when creating admin signature
  ///   - adminSignature: Admin signature authorizing the withdrawal
  public init(
    proxyAddress: Web3Core.EthereumAddress,
    tokenAddress: Web3Core.EthereumAddress,
    amount: BigUInt,
    recipientAddress: Web3Core.EthereumAddress,
    expiryAt: BigUInt,
    salt: Data,
    signature: Data,
    adminSalt: Data,
    adminSignature: Data
  ) {
    self.proxyAddress = proxyAddress
    self.tokenAddress = tokenAddress
    self.amount = amount
    self.recipientAddress = recipientAddress
    self.expiryAt = expiryAt
    self.salt = salt
    self.signature = signature
    self.adminSalt = adminSalt
    self.adminSignature = adminSignature
  }
}
