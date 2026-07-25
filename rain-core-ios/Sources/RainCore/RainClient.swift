import Foundation
import CoreGraphics
import Web3

/// The wallet-bound client surface resolved from `RainSdk.provider(_:)` / `RainSdk.first { }`.
///
/// Every method here operates against the single wallet provider this client was resolved for.
/// Wallet-agnostic building (EIP-712 message, withdraw calldata, transaction parameters) lives on
/// ``RainSdk`` instead, since it needs no resolved provider. Mirrors Android's `RainClient`.
public protocol RainClient: Sendable {
  // MARK: - Client metadata

  /// Identifier of the provider backing this client (e.g. ``ProviderId/portal``).
  var providerId: ProviderId { get }

  /// Optional behaviours the backing provider supports (see ``Capability``).
  var capabilities: Set<Capability> { get }

  /// Whether the SDK's chain configuration is set up. A `RainClient` only exists once its
  /// provider has resolved against a validated configuration, so this is always `true` for a
  /// live client.
  var isInitialized: Bool { get }

  /// Clears client-held state. A resolved client is immutable (configuration and the backing
  /// provider are fixed at resolution), so there is nothing to tear down at this level; the
  /// method is idempotent. Prefer ``RainSdk/reset()``, which evicts resolved clients so they
  /// re-resolve on next access.
  func reset()

  // MARK: - Collateral / fees

  /// Executes a collateral withdrawal transaction on-chain: builds the calldata, obtains the
  /// admin EIP-712 signature via the backing provider, and submits. Returns the transaction hash.
  func withdrawCollateral(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> String

  /// Estimates the total fee (estimated gas × gas price) to execute an arbitrary transaction,
  /// in the chain's native token (e.g. ETH, AVAX).
  ///
  /// - Parameters:
  ///   - chainId: Target network chain ID.
  ///   - from: Sender wallet address.
  ///   - to: Target contract address.
  ///   - data: Hex-encoded transaction calldata.
  func estimateGas(
    chainId: Int,
    from: String,
    to: String,
    data: String
  ) async throws -> Decimal

  /// Estimates the total fee (gas cost) to execute a collateral withdrawal, in the chain's
  /// native token.
  func estimateWithdrawalFee(
    chainId: Int,
    addresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String
  ) async throws -> Decimal

  // MARK: - Wallet information

  /// Returns the current wallet address (EVM EOA, 0x…).
  func getWalletAddress() async throws -> String

  /// Returns the wallet address for a specific chain's family (Solana account for Solana
  /// sentinel chains, EVM address otherwise).
  func getWalletAddress(chainId: Int) async throws -> String

  /// Generates a square QR code (PNG) encoding the current wallet address.
  func generateWalletAddressQRCode(
    dimension: Int,
    backgroundColor: CGColor?,
    foregroundColor: CGColor?
  ) async throws -> Data

  /// Generates a square QR code (PNG) encoding `address`, or the wallet's own address when
  /// `address` is `nil`.
  ///
  /// Use this for any address the host needs to show — a chain-specific wallet address (the
  /// Solana account rather than the EVM one), or a Rain collateral deposit address.
  ///
  /// - Parameters:
  ///   - address: Address to encode. `nil` encodes the provider's wallet address.
  ///   - dimension: Output width and height in pixels (the QR is square).
  ///   - backgroundColor: Background colour; `nil` uses black.
  ///   - foregroundColor: QR module colour; `nil` uses white.
  func generateAddressQRCode(
    address: String?,
    dimension: Int,
    backgroundColor: CGColor?,
    foregroundColor: CGColor?
  ) async throws -> Data

  // MARK: - Fetch balances

  /// Fetches a single balance (native or a contract token) for the current wallet.
  func getBalance(chainId: Int, token: Token) async throws -> Balance

  /// Fetches all non-zero balances (native always included) for the current wallet on a network.
  func getTokenBalances(chainId: Int) async throws -> [Balance]

  /// Fetches balances across every configured chain in parallel, flattened into one list.
  func getAllBalances() async throws -> [Balance]

  // MARK: - Transactions

  /// Fetches transaction history for the current wallet on the given network.
  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction]

  // MARK: - Send tokens

  /// Sends native tokens (e.g. ETH, AVAX) on the specified network.
  func sendNative(
    chainId: Int,
    to: String,
    amount: Decimal
  ) async throws -> RainTokenTransferResult

  /// Sends ERC-20 (EVM) or SPL (Solana) tokens depending on `chainId`. Pass `nil` decimals to let
  /// the SDK resolve them from its registry or an on-chain read.
  func sendToken(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Decimal,
    decimals: Int?
  ) async throws -> RainTokenTransferResult
}

public extension RainClient {
  /// Generates a 256 px QR code (PNG) with the default colours, encoding `address` — or the
  /// wallet's own address when `address` is omitted.
  func generateAddressQRCode(address: String? = nil) async throws -> Data {
    try await generateAddressQRCode(
      address: address,
      dimension: 256,
      backgroundColor: nil,
      foregroundColor: nil
    )
  }

  /// Sends tokens letting the SDK resolve the token's `decimals()` itself.
  func sendToken(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Decimal
  ) async throws -> RainTokenTransferResult {
    try await sendToken(
      chainId: chainId,
      contractAddress: contractAddress,
      to: to,
      amount: amount,
      decimals: nil
    )
  }
}
