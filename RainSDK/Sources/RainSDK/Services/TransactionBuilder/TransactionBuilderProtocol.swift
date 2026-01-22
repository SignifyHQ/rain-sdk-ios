import Foundation
import Web3

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
}
