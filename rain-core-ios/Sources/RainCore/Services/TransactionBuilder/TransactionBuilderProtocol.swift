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
  
  /// Whether `walletAddress` is an admin of the collateral contract at `proxyAddress`.
  /// - Returns: The contract's answer, or `nil` if the check could not be performed (RPC failure,
  ///   or a collateral that exposes no `isAdmin`). Callers must treat `nil` as unknown and
  ///   proceed, never as "not authorized".
  func isCollateralAdmin(
    proxyAddress: String,
    walletAddress: String,
    chainId: Int
  ) async -> Bool?

  /// Build EIP-712 message structure
  /// - Parameters:
  ///   - chainId: The chain identifier
  ///   - collateralProxyAddress: The collateral proxy contract address
  ///   - walletAddress: The user's wallet address
  ///   - tokenAddress: The token contract address
  ///   - amount: The withdrawal amount (already in base units as BigUInt)
  ///   - recipientAddress: The recipient address
  ///   - nonce: The nonce value
  ///   - salt: The salt as a hex string (e.g. 0x... for the EIP-712 domain)
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
    salt: String
  ) throws -> String
  
  /// ABI-encodes the `withdrawAsset` call executed against the collateral controller.
  ///
  /// Pure encoding: no RPC, so no chain id and no network failure mode.
  ///
  /// - Parameters:
  ///   - ethereumContractAddress: The collateral controller that will execute the withdrawal
  ///   - withdrawAssetParameter: The encoded call's arguments — see `WithdrawAssetParameter` for
  ///     which salt/signature pair belongs to Rain and which to the wallet
  /// - Returns: Hex-encoded transaction calldata (prefixed with "0x")
  /// - Throws: RainSDKError if ABI encoding or validation fails
  func buildErc20TransactionForWithdrawAsset(
    ethereumContractAddress: Web3Core.EthereumAddress,
    withdrawAssetParameter: WithdrawAssetParameter
  ) throws -> String

  /// ABI-encodes a `balanceOf(address)` call for the given wallet address on the given chain.
  /// - Parameters:
  ///   - walletAddress: The wallet address to encode as the `_owner` argument.
  ///   - chainId: The chain identifier used to resolve the RPC URL.
  /// - Returns: Hex-encoded calldata string (e.g. `"0x70a08231000…"`), or `""` on failure.
  func encodeBalanceOfCall(
    walletAddress: String,
    chainId: Int
  ) async throws -> String

  /// Builds ERC-20 transfer(to, amount) transaction data for sending tokens.
  ///
  /// - Parameters:
  ///   - chainId: The chain identifier (used to resolve RPC URL).
  ///   - contractAddress: The ERC-20 token contract address.
  ///   - walletAddress: The sender (from) address, used when building the transaction.
  ///   - toAddress: Recipient address.
  ///   - amount: Amount in the token's smallest unit (base units).
  /// - Returns: Hex-encoded calldata (prefixed with "0x") for the transfer call.
  /// - Throws: RainSDKError if RPC URL or addresses are invalid, or if encoding fails.
  func buildERC20TransferData(
    chainId: Int,
    contractAddress: String,
    walletAddress: String,
    toAddress: String,
    amount: BigUInt
  ) async throws -> String

  /// Builds ERC-20 `approve(spender, amount)` transaction data — the wallet-side prerequisite
  /// for Rain's Auth Pull.
  ///
  /// - Parameters:
  ///   - chainId: The chain identifier (used to resolve RPC URL).
  ///   - contractAddress: The ERC-20 token contract address.
  ///   - walletAddress: The approving (from) address.
  ///   - spender: The address being approved to move the token — Rain's operator for Auth Pull.
  ///   - amount: Allowance in the token's base units. `BigUInt` max means unlimited, `0` revokes.
  /// - Returns: Hex-encoded calldata (prefixed with "0x") for the approve call.
  /// - Throws: RainSDKError if RPC URL or addresses are invalid, or if encoding fails.
  func buildERC20ApproveData(
    chainId: Int,
    contractAddress: String,
    walletAddress: String,
    spender: String,
    amount: BigUInt
  ) async throws -> String
}
