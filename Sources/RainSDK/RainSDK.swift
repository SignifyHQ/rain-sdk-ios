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

  /// Sets the wallet provider used for send and other wallet operations (e.g. sendNative, sendERC20).
  /// Call after `initialize(networkConfigs:)` when using a third-party provider (e.g. Web3Auth).
  /// Pass `nil` to clear. When using Portal, prefer `initializePortal` which sets the provider automatically.
  func setWalletProvider(_ provider: (any RainWalletProvider)?)

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
  ///   - walletAddress: Address of the user wallet initiating the action (used as user in EIP-712 message).
  ///   - assetAddresses: A structure containing all required addresses:
  ///     - proxyAddress: Address of the collateral proxy contract (used as verifyingContract in EIP-712 domain).
  ///     - tokenAddress: ERC-20 token contract address (used as asset in EIP-712 message).
  ///     - recipientAddress: Final recipient of the funds (used as recipient in EIP-712 message).
  ///   - amount: Amount to be authorized, expressed in token's natural units (e.g., 100.0 for 100 tokens).
  ///   - decimals: Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC).
  ///   - nonce: Optional. The nonce value. If not provided, it will be retrieved from the contract.
  ///
  /// - Returns: A tuple containing:
  ///   - A serialized EIP-712 message ready for signing (String)
  ///   - The salt used in the message as a hex string (String)
  ///
  /// - Throws: An error if message construction fails or inputs are invalid.
  func buildEIP712Message(
    chainId: Int,
    walletAddress: String,
    assetAddresses: EIP712AssetAddresses,
    amount: Double,
    decimals: Int,
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
  ///   - assetAddresses: A structure containing all required addresses:
  ///     - contractAddress: Address of the main contract that will execute the withdrawal.
  ///     - proxyAddress: Address of the collateral proxy contract (used for the withdrawal function call).
  ///     - tokenAddress: ERC-20 token contract address.
  ///     - recipientAddress: Address receiving the withdrawal.
  ///   - amount: Amount to be withdrawn, expressed in token's natural units (e.g., 100.0 for 100 tokens).
  ///   - decimals: Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC).
  ///   - expiresAt: Expiration timestamp after which the transaction is invalid (Unix timestamp string).
  ///   - salt: User salt data (32 bytes) for the withdrawal authorization.
  ///   - signatureData: User or wallet signature data from Rain API.
  ///   - adminSalt: Admin salt generated when creating admin signature (same salt used in buildEIP712Message).
  ///   - adminSignature: Admin signature authorizing the withdrawal.
  ///
  /// - Returns: Hex-encoded transaction calldata (prefixed with "0x").
  ///
  /// - Throws: An error if ABI encoding or validation fails.
  func buildWithdrawTransactionData(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    expiresAt: String,
    salt: Data,
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
  ///   - transactionData: Hex-encoded calldata.
  ///
  /// - Returns: A fully formed `ETHTransactionParam` object.
  func composeTransactionParameters(
    walletAddress: String,
    contractAddress: String,
    transactionData: String
  ) -> ETHTransactionParam
  
  /// Executes a collateral withdrawal transaction on-chain.
  ///
  /// This method orchestrates the full withdrawal flow, including:
  /// - Preparing transaction calldata
  /// - Managing or fetching the correct nonce (if not provided)
  /// - Signing the transaction using the Portal wallet
  /// - Submitting the transaction to the specified blockchain network
  ///
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier.
  ///   - assetAddresses: A structure containing all required addresses:
  ///     - contractAddress: Address of the main contract that will execute the withdrawal (used as transaction target).
  ///     - proxyAddress: Address of the collateral proxy contract (used for EIP-712 message and transaction data).
  ///     - tokenAddress: ERC-20 token contract address.
  ///     - recipientAddress: Address that will receive the withdrawn funds.
  ///   - amount: Human-readable token amount to withdraw.
  ///   - decimals: Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC).
  ///   - salt: Salt for the user's withdrawal authorization (base64-encoded string, 32 bytes decoded).
  ///   - signature: User or wallet signature data from Rain API (hex string format, 65 bytes).
  ///   - expiresAt: Expiration timestamp after which the transaction is invalid (Unix timestamp string or ISO8601 format).
  ///   - nonce: Optional transaction nonce.
  ///            If `nil`, the SDK is responsible for resolving the correct nonce.
  ///
  /// - Returns: The transaction hash of the submitted on-chain transaction.
  ///
  /// - Throws: An error if transaction construction, signing, or submission fails.
  func withdrawCollateral(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?,
  ) async throws -> String
  
  /// Estimates the total fee (gas cost) required to execute a collateral withdrawal transaction.
  ///
  /// This method builds the withdrawal transaction parameters and uses the network to estimate
  /// gas usage and current gas price, returning the total fee in the chain's native token (e.g., ETH).
  ///
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier.
  ///   - addresses: A structure containing all required addresses (contract, proxy, recipient, token).
  ///   - amount: Human-readable token amount to withdraw.
  ///   - decimals: Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC).
  ///   - salt: Salt for the user's withdrawal authorization (base64-encoded string, 32 bytes decoded).
  ///   - signature: User or wallet signature data from Rain API (hex string format, 65 bytes).
  ///   - expiresAt: Expiration timestamp after which the transaction is invalid (Unix timestamp string or ISO8601 format).
  ///
  /// - Returns: The estimated withdrawal fee in the chain's native token (e.g., ETH).
  ///
  /// - Throws: An error if fee estimation fails (e.g., SDK not initialized, invalid response, or network error).
  func estimateWithdrawalFee(
    chainId: Int,
    addresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String
  ) async throws -> Double

  // MARK: - Fetch balances

  /// Fetches the native token balance (e.g. ETH) for the current wallet on the given network.
  ///
  /// - Parameter chainId: The target blockchain network identifier (e.g. 1 for Ethereum, 43114 for Avalanche).
  /// - Returns: Balance in human-readable form (e.g. 1.5 for 1.5 ETH).
  /// - Throws: RainSDKError if SDK or wallet provider is not initialized, or if the RPC request fails.
  func getNativeBalance(
    chainId: Int
  ) async throws -> Double

  /// Fetches the ERC-20 token balance for a single token for the current wallet on the given network.
  ///
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier (e.g. 1 for Ethereum).
  ///   - tokenAddress: The ERC-20 token contract address.
  /// - Returns: Balance in human-readable form (e.g. 100.0 for 100 tokens), or nil if the wallet has no balance for this token or the token is not in the balance list.
  /// - Throws: RainSDKError if wallet provider is not set, or if the request fails.
  func getERC20Balance(
    chainId: Int,
    tokenAddress: String
  ) async throws -> Double?

  /// Fetches ERC-20 token balances for the current wallet on the given network.
  ///
  /// - Parameter chainId: The target blockchain network identifier (e.g. 1 for Ethereum).
  /// - Returns: Dictionary mapping token contract address to balance (human-readable). Empty if none or on error.
  /// - Throws: RainSDKError if SDK or Portal is not initialized, or if the request fails.
  func getERC20Balances(
    chainId: Int
  ) async throws -> [String: Double]

  /// Fetches all balances (native + ERC-20) for the current wallet on the given network.
  ///
  /// - Parameter chainId: The target blockchain network identifier (e.g. 1 for Ethereum).
  /// - Returns: Dictionary mapping token contract address to balance (human-readable). Use key `""` for native token (e.g. ETH).
  /// - Throws: RainSDKError if wallet provider is not set, or if the request fails.
  func getBalances(
    chainId: Int
  ) async throws -> [String: Double]

  // MARK: - Send tokens

  /// Sends native tokens (e.g. ETH, AVAX) on the specified network.
  ///
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier (e.g. 1 for Ethereum, 43114 for Avalanche).
  ///   - to: Recipient address.
  ///   - amount: Human-readable amount (e.g. 1.5 for 1.5 ETH).
  /// - Returns: The transaction hash of the submitted transaction.
  /// - Throws: RainSDKError if no wallet provider is set, or if transaction building or submission fails.
  func sendNativeToken(
    chainId: Int,
    to: String,
    amount: Double
  ) async throws -> String

  /// Sends ERC-20 tokens on the specified network.
  ///
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier.
  ///   - contractAddress: The ERC-20 token contract address.
  ///   - to: Recipient address.
  ///   - amount: Human-readable amount (e.g. 100.0 for 100 tokens).
  ///   - decimals: Number of decimal places for the token (e.g. 18 for WETH, 6 for USDC).
  /// - Returns: The transaction hash of the submitted transaction.
  /// - Throws: RainSDKError if SDK or wallet provider is not initialized, or if transaction building or submission fails.
  func sendERC20Token(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Double,
    decimals: Int
  ) async throws -> String
}
