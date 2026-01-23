import Foundation
import PortalSwift
import Web3

// Declaration of Portal wallet instance and the init method
public protocol RainSDK {
  /// The initialized Portal instance
  var portal: Portal { get throws }
  
  /// Initializes the SDK with a Portal token and network configurations
  /// - Parameters:
  ///   - portalSessionToken: A valid Portal session token
  ///   - networkConfigs: Array of network configurations, each containing chain ID and RPC URL
  ///     Example: [NetworkConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/..."),
  ///               NetworkConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")]
  /// - Throws: RainSDKError if initialization fails (e.g., invalid token, invalid RPC URLs)
  func initializePortal(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) async throws
  
  /// Initializes the SDK with network configurations only (wallet-agnostic mode)
  /// This allows using transaction building methods without Portal wallet integration
  /// - Parameters:
  ///   - networkConfigs: Array of network configurations, each containing chain ID and RPC URL
  ///     Example: [NetworkConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/..."),
  ///               NetworkConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")]
  /// - Throws: RainSDKError if initialization fails (e.g., invalid RPC URLs)
  func initialize(
    networkConfigs: [NetworkConfig]
  ) async throws
  
  /// Builds an EIP-712 compliant message used for obtaining the admin signature
  /// required for withdrawals.
  ///
  /// This method is expected to:
  /// - Construct the typed data payload according to the contract specification
  /// - Convert the amount to base units using the provided decimals
  /// - Return a serialized representation ready for signing
  ///
  /// - Parameters:
  ///   - chainId: ChainId of the current network.
  ///   - collateralProxyAddress: Address of the collateral proxy contract.
  ///   - walletAddress: Address of the user wallet initiating the action.
  ///   - tokenAddress: ERC-20 token contract address.
  ///   - amount: Amount to be authorized, expressed in token's natural units (e.g., 100.0 for 100 tokens).
  ///   - decimals: Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC).
  ///   - recipientAddress: Final recipient of the funds.
  ///   - nonce: Optional. The nonce value. If not provided, it will be retrieved from the contract.
  ///
  /// - Returns: A tuple containing:
  ///   - A serialized EIP-712 message ready for signing (String)
  ///   - The salt used in the message as a hex string (String)
  ///
  /// - Throws: An error if message construction fails or inputs are invalid.
  func buildEIP712Message(
    chainId: Int,
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: Double,
    decimals: Int,
    recipientAddress: String,
    nonce: BigUInt?
  ) async throws -> (String, String)
  
  /// Builds the encoded transaction calldata required to execute a withdrawal
  /// on the collateral proxy contract.
  ///
  /// This method is expected to:
  /// - ABI-encode the contract function call
  /// - Include the admin signature and authorization data
  /// - Convert the amount to base units using the provided decimals
  ///
  /// - Parameters:
  ///   - chainId: ChainId of the current network.
  ///   - contractAddress: Address of the main contract that will execute the withdrawal.
  ///   - proxyAddress: Address of the collateral proxy contract.
  ///   - tokenAddress: ERC-20 token contract address.
  ///   - amount: Amount to be withdrawn, expressed in token's natural units (e.g., 100.0 for 100 tokens).
  ///   - decimals: Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC).
  ///   - recipientAddress: Address receiving the withdrawal.
  ///   - expiresAt: Expiration timestamp after which the transaction is invalid (Unix timestamp string).
  ///   - signatureData: User or wallet signature data from Rain API.
  ///   - adminSalt: Admin salt generated when creating admin signature (same salt used in buildEIP712Message).
  ///   - adminSignature: Admin signature authorizing the withdrawal.
  ///
  /// - Returns: Hex-encoded transaction calldata (prefixed with "0x").
  ///
  /// - Throws: An error if ABI encoding or validation fails.
  func buildWithdrawTransactionData(
    chainId: Int,
    contractAddress: String,
    proxyAddress: String,
    tokenAddress: String,
    amount: Double,
    decimals: Int,
    recipientAddress: String,
    expiresAt: String,
    signatureData: Data,
    adminSalt: Data,
    adminSignature: Data
  ) async throws -> String
  
  /// Composes Ethereum transaction parameters required to submit a transaction
  /// to the network.
  ///
  /// This method is expected to:
  /// - Populate the `to` address and calldata
  /// - Leave gas, nonce, and fee calculation to the caller or wallet layer
  ///
  /// - Parameters:
  ///   - walletAddress: Address of the sender wallet.
  ///   - contractAddress: Target smart contract address.
  ///   - amount: Transaction value amount in ETH (will be converted to Wei).
  ///   - transactionData: Hex-encoded calldata.
  ///
  /// - Returns: A fully formed `ETHTransactionParam` object.
  func composeTransactionParameters(
    walletAddress: String,
    contractAddress: String,
    amount: Double,
    transactionData: String
  ) -> ETHTransactionParam
}
