import Foundation
import CoreGraphics
import Web3

/// The wallet-bound client surface resolved from `RainSdk.provider(_:)` / `RainSdk.first { }`.
///
/// Every method here operates against the single wallet provider this client was resolved for.
/// Wallet-agnostic building (EIP-712 message, withdraw calldata, transaction parameters) lives on
/// ``RainSdk`` instead, since it needs no resolved provider.
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

  /// Executes a collateral withdrawal on-chain and returns the transaction hash (EVM) or
  /// transaction signature (Solana). `decimals` scales `amount` on every chain including Solana,
  /// where it is not checked against the SPL mint — pass the mint's real decimals.
  func withdrawCollateral(
    chainId: Int,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    adminSignature: RainAdminSignature,
    nonce: BigUInt?
  ) async throws -> String

  /// Builds a collateral withdrawal without broadcasting it. See ``RainPreparedWithdrawal`` for
  /// what this does and does not do offline, and for the Solana blockhash lifetime.
  func prepareWithdrawal(
    chainId: Int,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    adminSignature: RainAdminSignature,
    nonce: BigUInt?
  ) async throws -> RainPreparedWithdrawal

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
  /// native token. EVM only — throws on a Solana chain id.
  ///
  /// Builds — and therefore **signs** — a complete withdrawal to estimate against, so the wallet
  /// prompts for an EIP-712 signature (e.g. Turnkey biometrics) even though nothing broadcasts.
  /// To quote a fee without a second prompt, call ``prepareWithdrawal(chainId:addresses:amount:decimals:adminSignature:nonce:)``
  /// once and estimate on the result with ``estimateWithdrawalFee(chainId:prepared:)``.
  func estimateWithdrawalFee(
    chainId: Int,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    adminSignature: RainAdminSignature,
    nonce: BigUInt?
  ) async throws -> Decimal

  /// Estimates the total fee (gas cost) for an already-prepared withdrawal, in the chain's native
  /// token, without building or signing anything new — no wallet prompt. EVM only — throws on a
  /// Solana preparation.
  func estimateWithdrawalFee(
    chainId: Int,
    prepared: RainPreparedWithdrawal
  ) async throws -> Decimal

  // MARK: - Wallet information

  /// Returns the current wallet address (EVM EOA, 0x…).
  func getWalletAddress() async throws -> String

  /// Returns the wallet address for a specific chain's family (Solana account for Solana
  /// sentinel chains, EVM address otherwise).
  func getWalletAddress(chainId: Int) async throws -> String

  /// Generates a square QR code (PNG) encoding the current wallet address.
  @available(
    *, deprecated,
    message: "Call generateAddressQRCode(address: nil, …) — it encodes the wallet's own address when address is nil."
  )
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
  ///   - backgroundColor: Background colour; `nil` uses white.
  ///   - foregroundColor: QR module colour; `nil` uses black.
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
    order: RainTransactionOrder?
  ) async throws -> [RainTransaction]

  // MARK: - Send tokens

  /// Sends native tokens (e.g. ETH, AVAX) on the specified network.
  func sendNative(
    chainId: Int,
    to: String,
    amount: Decimal
  ) async throws -> RainTokenTransferResult

  /// Sends ERC-20 (EVM) or SPL (Solana) tokens depending on `chainId`. Pass `nil` decimals to let
  /// the SDK resolve them from its registry or an on-chain read. On Solana `decimals` never scales
  /// the amount: the mint's own value is read from the chain and enforced by `TransferChecked`.
  func sendToken(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Decimal,
    decimals: Int?
  ) async throws -> RainTokenTransferResult

  // MARK: - Token metadata

  /// Registers token metadata so balance and transfer calls can resolve symbol/decimals without an
  /// on-chain read. Additive: re-registering an address replaces its entry.
  func registerTokens(_ tokens: [TokenInfo])
}

public extension RainClient {
  /// Withdraws collateral, letting the SDK read the collateral's current nonce on chain.
  func withdrawCollateral(
    chainId: Int,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    adminSignature: RainAdminSignature
  ) async throws -> String {
    try await withdrawCollateral(
      chainId: chainId,
      addresses: addresses,
      amount: amount,
      decimals: decimals,
      adminSignature: adminSignature,
      nonce: nil
    )
  }

  /// Prepares a withdrawal, letting the SDK read the collateral's current nonce on chain.
  func prepareWithdrawal(
    chainId: Int,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    adminSignature: RainAdminSignature
  ) async throws -> RainPreparedWithdrawal {
    try await prepareWithdrawal(
      chainId: chainId,
      addresses: addresses,
      amount: amount,
      decimals: decimals,
      adminSignature: adminSignature,
      nonce: nil
    )
  }

  /// Estimates the withdrawal fee, letting the SDK read the collateral's current nonce on chain.
  func estimateWithdrawalFee(
    chainId: Int,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    adminSignature: RainAdminSignature
  ) async throws -> Decimal {
    try await estimateWithdrawalFee(
      chainId: chainId,
      addresses: addresses,
      amount: amount,
      decimals: decimals,
      adminSignature: adminSignature,
      nonce: nil
    )
  }

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

  /// Fetches transaction history with the provider's defaults. Reduced-arity on purpose: a
  /// full-signature extension member would be a self-calling default witness.
  func getTransactions(chainId: Int) async throws -> [RainTransaction] {
    try await getTransactions(
      chainId: chainId,
      limit: nil,
      offset: nil,
      order: nil
    )
  }
}
