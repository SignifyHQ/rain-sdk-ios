import Foundation
import Web3
import Web3Core

/// Protocol for building transaction components
/// Handles EIP-712 message generation, contract interactions, and ABI management
protocol TransactionBuilderProtocol {
  /// Generate random 32-byte salt for EIP-712 domain
  func generateSalt() -> Data
  
  /// Get latest nonce from contract
  /// - Parameters:
  ///   - proxyAddress: The proxy contract address
  ///   - chainId: The chain identifier
  /// - Returns: The latest nonce as BigUInt
  /// - Throws: RainSDKError if nonce retrieval fails
  func getLatestNonce(
    proxyAddress: String,
    chainId: Int
  ) async throws -> BigUInt
  
  /// Build EIP-712 message structure
  /// - Parameters:
  ///   - chainId: The chain identifier
  ///   - collateralProxyAddress: The collateral proxy contract address
  ///   - walletAddress: The user's wallet address
  ///   - tokenAddress: The token contract address
  ///   - amount: The withdrawal amount (already in base units as BigUInt)
  ///   - recipientAddress: The recipient address
  ///   - nonce: The nonce value
  ///   - salt: The salt data (32 bytes)
  /// - Returns: Serialized EIP-712 message string
  /// - Throws: RainSDKError if message building fails
  func buildEIP712Message(
    chainId: Int,
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: BigUInt,
    recipientAddress: String,
    nonce: BigUInt,
    salt: Data
  ) throws -> String
  
  /// Builds the encoded transaction calldata required to execute a withdrawal
  /// on the collateral proxy contract.
  ///
  /// This method ABI-encodes the contract function call with the provided
  /// withdrawal parameters and returns the hex-encoded calldata.
  ///
  /// - Parameters:
  ///   - chainId: The chain identifier for the target network
  ///   - ethereumContractAddress: The main contract address that will execute the withdrawal
  ///   - withdrawAssetParameter: A `WithdrawAssetParameter` struct containing:
  ///     - proxyAddress: Address of the collateral proxy contract
  ///     - tokenAddress: ERC-20 token contract address
  ///     - amount: Withdrawal amount in base units (BigUInt)
  ///     - recipientAddress: Address receiving the withdrawal
  ///     - expiryAt: Expiration timestamp (Unix timestamp as BigUInt)
  ///     - salt: Salt data for the user signature
  ///     - signature: User signature data from Rain API
  ///     - adminSalt: Admin salt generated when creating admin signature
  ///     - adminSignature: Admin signature authorizing the withdrawal
  /// - Returns: Hex-encoded transaction calldata (prefixed with "0x")
  /// - Throws: RainSDKError if ABI encoding, contract interaction, or validation fails
  func buildErc20TransactionForWithdrawAsset(
    chainId: Int,
    ethereumContractAddress: Web3Core.EthereumAddress,
    withdrawAssetParameter: WithdrawAssetParameter
  ) async throws -> String
}
