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
  /// - Returns: A serialized EIP-712 message ready for signing.
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
  ) async throws -> String
}
