import Foundation
import UIKit
import RainCore
import RainPortal
import Web3
import Web3Core
import web3swift
import PortalSwift
import TurnkeySwift

/// Service class for managing Rain SDK operations.
///
/// Migrated to the modular SDK: instead of a single `RainSDKManager`, it holds a built
/// ``RainSdk`` (the registry, which also carries the wallet-agnostic building methods) plus the
/// resolved ``RainClient`` for the active provider. Mirrors the Android sample's `RainSession`.
@MainActor
class RainSDKService: ObservableObject {
  // MARK: - Singleton

  /// Shared instance of the service
  static let shared = RainSDKService()

  // MARK: - Properties

  /// The built SDK registry. Holds wallet-agnostic building methods (EIP-712, withdraw calldata)
  /// and resolves provider-backed clients. Nil until an `initialize*` runs. Rebuilt per provider.
  private var rain: RainSdk?

  /// The provider-backed client (address, balances, send, withdraw). Nil until a provider is
  /// resolved; nil in wallet-agnostic mode.
  private var client: RainClient?

  /// The underlying Portal instance captured during Portal resolution, for Portal-only flows
  /// (wallet recover/backup) that aren't part of the Rain port. Nil unless Portal is active.
  private var portalInstance: Portal?

  /// Active wallet provider (or `.none` for wallet-agnostic mode).
  enum ActiveProvider {
    case none
    case portal
    case turnkey
  }

  /// Current initialization state
  @Published var isInitialized = false

  /// Active provider after the last successful initialize. Used by demo views to gate provider-specific UI (e.g. Portal recover sheet).
  @Published var activeProvider: ActiveProvider = .none

  /// Network the feature screens operate on, selected via the connection-screen dropdown.
  @Published var selectedChain: WalletChain = .baseSepolia

  // MARK: - Initialization

  private init() {}

  /// Current error state
  @Published var error: RainSDKError?

  /// Current initialization status message
  @Published var statusMessage: String = "Not initialized"

  // MARK: - Initialization

  /// Initialize the SDK with Portal token and network configurations.
  /// Builds a `RainSdk` with a `PortalProvider` and resolves the Portal-backed client.
  /// - Parameters:
  ///   - portalToken: Portal session token
  ///   - networkConfigs: Array of network configurations
  func initialize(portalToken: String, networkConfigs: [NetworkConfig]) async {
    statusMessage = "Initializing..."
    error = nil

    do {
      // Enable logging for demo
      RainLogger.isEnabled = true

      // Capture the underlying Portal instance for Portal-only flows (recover/backup).
      let capturedPortal = PortalInstanceBox()
      let sdk = try RainSdk.builder()
        .rpcEndpoints(networkConfigs)
        .register(PortalProvider(PortalConfig(sessionToken: portalToken)) { portal in
          capturedPortal.set(portal)
        })
        .build()

      let resolvedClient = try await sdk.provider(.portal)

      // Fetch the wallet address to ensure the session token is valid
      print("Rain SDK: wallet address \(try await resolvedClient.getWalletAddress())")

      rain = sdk
      client = resolvedClient
      portalInstance = capturedPortal.value
      isInitialized = true
      activeProvider = .portal
      statusMessage = "Initialized successfully with \(networkConfigs.count) network(s)"
      error = nil
    } catch let sdkError as RainSDKError {
      resetState()
      error = sdkError
      statusMessage = "Initialization failed: \(sdkError.errorCode)"
    } catch {
      resetState()
      self.error = RainSDKError.providerError(underlying: error)
      statusMessage = "Initialization failed: Unknown error"
    }
  }

  /// Initialize the SDK with an authenticated `TurnkeyContext` and network configurations.
  /// Builds a `RainSdk` with a `TurnkeyProvider` and resolves the Turnkey-backed client.
  /// - Parameters:
  ///   - turnkey: A `TurnkeyContext` whose `authState == .authenticated`. Auth (passkey, OTP, etc.) is the host app's responsibility.
  ///   - networkConfigs: Array of network configurations.
  ///   - walletAddress: Optional override; otherwise the first Ethereum-format account from the Turnkey context is used.
  func initializeTurnkey(
    turnkey: TurnkeyContext,
    networkConfigs: [NetworkConfig],
    walletAddress: String? = nil
  ) async {
    statusMessage = "Initializing (Turnkey)..."
    error = nil

    do {
      RainLogger.isEnabled = true

      let sdk = try RainSdk.builder()
        .rpcEndpoints(networkConfigs)
        .register(TurnkeyProvider(TurnkeyConfig(turnkey: turnkey, walletAddress: walletAddress)))
        .build()

      let resolvedClient = try await sdk.provider(.turnkey)

      print("Rain SDK: wallet address \(try await resolvedClient.getWalletAddress())")

      rain = sdk
      client = resolvedClient
      portalInstance = nil
      isInitialized = true
      activeProvider = .turnkey
      statusMessage = "Initialized successfully (Turnkey) with \(networkConfigs.count) network(s)"
      error = nil
    } catch let sdkError as RainSDKError {
      resetState()
      error = sdkError
      statusMessage = "Initialization failed: \(sdkError.errorCode)"
    } catch {
      resetState()
      self.error = RainSDKError.providerError(underlying: error)
      statusMessage = "Initialization failed: Unknown error"
    }
  }

  /// Initialize the SDK in wallet-agnostic mode (no wallet provider).
  /// Builds a `RainSdk` with only RPC endpoints — the transaction-building methods work; no
  /// provider-backed client is resolved.
  /// - Parameters:
  ///   - networkConfigs: Array of network configurations
  func initializeWalletAgnostic(networkConfigs: [NetworkConfig]) async {
    statusMessage = "Initializing (wallet-agnostic)..."
    error = nil

    do {
      // Enable logging for demo
      RainLogger.isEnabled = true

      let sdk = try RainSdk.builder()
        .rpcEndpoints(networkConfigs)
        .build()

      rain = sdk
      client = nil
      portalInstance = nil
      isInitialized = true
      activeProvider = .none
      statusMessage = "Initialized successfully (wallet-agnostic) with \(networkConfigs.count) network(s)"
      error = nil
    } catch let sdkError as RainSDKError {
      resetState()
      error = sdkError
      statusMessage = "Initialization failed: \(sdkError.errorCode)"
    } catch {
      resetState()
      self.error = RainSDKError.providerError(underlying: error)
      statusMessage = "Initialization failed: Unknown error"
    }
  }

  /// The built registry, or throws `sdkNotInitialized` if no `initialize*` has run.
  private func requireRain() throws -> RainSdk {
    guard let rain else { throw RainSDKError.sdkNotInitialized }
    return rain
  }

  /// The resolved provider client, or throws `sdkNotInitialized` if none is active
  /// (e.g. wallet-agnostic mode, or before initialization).
  private func requireClient() throws -> RainClient {
    guard let client else { throw RainSDKError.sdkNotInitialized }
    return client
  }
  
  // MARK: - Transaction Building Methods
  
  /// Build EIP-712 message
  func buildEIP712Message(
    chainId: Int,
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: Decimal,
    decimals: Int,
    recipientAddress: String,
    nonce: BigUInt?
  ) async throws -> (String, String) {
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: collateralProxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
    return try await requireRain().buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    )
  }
  
  /// Build withdraw transaction data
  func buildWithdrawTransactionData(
    chainId: Int,
    contractAddress: String,
    proxyAddress: String,
    tokenAddress: String,
    amount: Decimal,
    decimals: Int,
    recipientAddress: String,
    expiresAt: String,
    signatureData: Data,
    adminSalt: Data,
    adminSignature: Data
  ) async throws -> String {
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
    return try await requireRain().buildWithdrawTransactionData(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      expiresAt: expiresAt,
      salt: adminSalt,
      signatureData: signatureData,
      adminSalt: adminSalt,
      adminSignature: adminSignature
    )
  }
  
  // MARK: - Wallet Address & QR

  /// Returns the current wallet address from the wallet provider.
  func getWalletAddress() async throws -> String {
    try await requireClient().getWalletAddress()
  }

  /// Returns the wallet address for a specific chain (Solana account for Solana sentinel
  /// chains, EVM address otherwise).
  func getWalletAddress(chainId: Int) async throws -> String {
    try await requireClient().getWalletAddress(chainId: chainId)
  }

  /// Generates a QR code image (PNG) encoding the current wallet address.
  func generateWalletAddressQRCode(
    dimension: Int = 256,
    backgroundColor: CGColor? = nil,
    foregroundColor: CGColor? = nil
  ) async throws -> Data {
    try await requireClient().generateWalletAddressQRCode(
      dimension: dimension,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor
    )
  }

  // NOTE: the SDK now returns precise `Balance` values; these wrappers adapt to the legacy
  // `Double` / `[String: Double]` shapes the demo UI expects. The `Balance` type is not named
  // directly because web3swift/PortalSwift also export a `Balance` (and the module name
  // `RainSDK` collides with the `RainSDK` protocol, so it can't be qualified) — the element
  // type is left to inference instead.

  /// Fetches the native token balance (e.g. ETH, AVAX, SOL) for the current wallet on the given network.
  func getNativeBalance(chainId: Int) async throws -> Double {
    let balance = try await requireClient().getBalance(chainId: chainId, token: .native)
    return NSDecimalNumber(decimal: balance.decimalAmount).doubleValue
  }

  /// Fetches the balance for a single contract token (ERC-20 or SPL mint).
  /// `decimals` is accepted for source compatibility; the SDK now resolves decimals itself.
  func getERC20Balance(chainId: Int, tokenAddress: String, decimals: Int? = nil) async throws -> Double {
    let balance = try await requireClient().getBalance(
      chainId: chainId,
      token: .contract(address: tokenAddress)
    )
    return NSDecimalNumber(decimal: balance.decimalAmount).doubleValue
  }

  /// Resolves a contract token's display metadata (symbol/name/decimals) on-chain.
  ///
  /// The Rain `/contracts` endpoint omits token symbol/decimals, so callers resolve them via
  /// the SDK (the `Balance` carries them). Best-effort: returns `nil` if the read fails — e.g.
  /// the SDK wasn't initialized with this contract's chain RPC.
  func resolveTokenMetadata(
    chainId: Int,
    tokenAddress: String
  ) async -> (symbol: String?, name: String?, decimals: Int)? {
    guard let client = try? requireClient(),
          let balance = try? await client.getBalance(
      chainId: chainId,
      token: .contract(address: tokenAddress)
    ) else {
      return nil
    }
    return (balance.symbol, balance.name, balance.decimals)
  }

  /// Discovers every contract token the wallet holds with a balance > 0. Each entry already
  /// carries the resolved symbol / name / decimals (from the SDK's registry or an on-chain
  /// read), so the UI can list tokens to pick instead of asking for a contract address.
  func getTokenBalances(chainId: Int) async throws -> [DiscoveredTokenBalance] {
    let balances = try await requireClient().getTokenBalances(chainId: chainId)
    return balances.compactMap { balance -> DiscoveredTokenBalance? in
      guard case .contract(let address) = balance.token else { return nil }
      return DiscoveredTokenBalance(
        address: address,
        symbol: balance.symbol,
        name: balance.name,
        decimals: balance.decimals,
        balance: NSDecimalNumber(decimal: balance.decimalAmount).doubleValue
      )
    }
    .filter { $0.balance > 0 }
  }

  /// Fetches all balances for the current wallet on the given network, keyed for display:
  /// the native balance uses key "", contract tokens use their symbol (falling back to address).
  func getBalances(chainId: Int) async throws -> [String: Double] {
    let balances = try await requireClient().getTokenBalances(chainId: chainId)
    var output: [String: Double] = [:]
    for balance in balances {
      let key: String
      switch balance.token {
      case .native:
        key = ""
      case .contract(let address):
        key = balance.symbol ?? address.lowercased()
      }
      output[key] = NSDecimalNumber(decimal: balance.decimalAmount).doubleValue
    }
    return output
  }

  /// Fetches balances across every configured chain, grouped by chain id then keyed as above.
  /// Per-chain failures are tolerated by the SDK, so one bad RPC doesn't hide the rest.
  func getAllBalances() async throws -> [Int: [String: Double]] {
    let balances = try await requireClient().getAllBalances()
    var output: [Int: [String: Double]] = [:]
    for balance in balances {
      let key: String
      switch balance.token {
      case .native:
        key = ""
      case .contract(let address):
        key = balance.symbol ?? address.lowercased()
      }
      output[balance.chainId, default: [:]][key] = NSDecimalNumber(decimal: balance.decimalAmount).doubleValue
    }
    return output
  }

  /// Fetches transaction history for the current wallet on the given network.
  func getTransactions(
    chainId: Int,
    limit: Int? = nil,
    offset: Int? = nil,
    order: WalletTransactionOrder? = nil
  ) async throws -> [WalletTransaction] {
    try await requireClient().getTransactions(
      chainId: chainId,
      limit: limit,
      offset: offset,
      order: order
    )
  }

  /// Sends native tokens (e.g. ETH, AVAX, SOL) from the current wallet.
  func sendNativeToken(chainId: Int, to: String, amount: Decimal) async throws -> RainTokenTransferResult {
    try await requireClient().sendNative(chainId: chainId, to: to, amount: amount)
  }

  /// Sends ERC-20 (EVM) or SPL (Solana) tokens from the current wallet.
  /// `decimals` is optional; when omitted the SDK resolves it (registry or on-chain read).
  func sendToken(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Decimal,
    decimals: Int? = nil
  ) async throws -> RainTokenTransferResult {
    try await requireClient().sendToken(
      chainId: chainId,
      contractAddress: contractAddress,
      to: to,
      amount: amount,
      decimals: decimals
    )
  }

  // MARK: - Collateral Withdraw

  /// Execute collateral withdrawal (build, sign, submit). Requires a wallet provider (Portal or Turnkey).
  func withdrawCollateral(
    chainId: Int,
    contractAddress: String,
    proxyAddress: String,
    tokenAddress: String,
    recipientAddress: String,
    amount: Decimal,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> String {
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
    return try await requireClient().withdrawCollateral(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      salt: salt,
      signature: signature,
      expiresAt: expiresAt,
      nonce: nonce
    )
  }

  // MARK: - Collateral Withdraw View Model

  /// Returns a new Collateral Withdraw demo view model for use in navigation or other screens.
  func makeCollateralWithdrawDemoViewModel() -> CollateralWithdrawDemoViewModel {
    CollateralWithdrawDemoViewModel()
  }

  // MARK: - Portal Access

  /// True when Portal is the active provider (its underlying instance was captured).
  var hasPortal: Bool {
    portalInstance != nil
  }

  /// True when any wallet provider (Portal or Turnkey) is active.
  var hasWalletProvider: Bool {
    activeProvider != .none
  }

  /// Recovers the Portal wallet from backup.
  /// - Parameters:
  ///   - backupMethod: `.iCloud` or `.PIN` (password).
  ///   - password: Required when backupMethod is `.PIN` (password); passed to `portal.setPassword` before recover.
  ///   - cipherText: Encrypted backup data (e.g. from iCloud or password storage).
  func recover(
    backupMethod: BackupMethods,
    password: String? = nil,
    cipherText: String
  ) async throws {
    let portal = try getPortal()

    if let password, backupMethod == .Password {
      try portal.setPassword(password)
    }

    do {
      _ = try await portal.recoverWallet(backupMethod, withCipherText: cipherText) { status in
        print("Rain SDK: Recover status: \(status)")
      }
      print("Rain SDK: Wallet recover success")
    } catch {
      print("Rain SDK: Recover failed - \(error.localizedDescription)")
      throw RainSDKError.providerError(underlying: error)
    }
  }

  /// The underlying Portal instance captured when Portal was resolved (see `initialize`).
  /// Portal-only flows (recover/backup) use this since they aren't part of the Rain port.
  private func getPortal() throws -> Portal {
    guard let portalInstance else {
      throw RainSDKError.sdkNotInitialized
    }
    return portalInstance
  }

  // MARK: - Reset

  /// Reset the SDK state — drop the built registry and resolved client.
  func reset() {
    resetState()
    error = nil
    statusMessage = "Reset"
  }

  /// Clears the built SDK, resolved client, and published state flags.
  private func resetState() {
    rain = nil
    client = nil
    portalInstance = nil
    isInitialized = false
    activeProvider = .none
  }
}

/// Thread-safe holder for the underlying `Portal` captured via `PortalProvider`'s `onPortalCreated`
/// hook. The hook is `@Sendable` and may fire off the main actor during provider resolution, so the
/// captured instance is stashed here and read back after `build()`/`provider(_:)` complete.
final class PortalInstanceBox: @unchecked Sendable {
  private let lock = NSLock()
  private var portal: Portal?

  func set(_ portal: Portal) {
    lock.lock(); defer { lock.unlock() }
    self.portal = portal
  }

  var value: Portal? {
    lock.lock(); defer { lock.unlock() }
    return portal
  }
}

/// A discovered contract-token balance with resolved display metadata, for the Balances UI.
struct DiscoveredTokenBalance: Identifiable {
  let address: String
  let symbol: String?
  let name: String?
  let decimals: Int
  let balance: Double

  var id: String { address }

  var displayAddress: String {
    address.count > 12 ? "\(address.prefix(6))…\(address.suffix(4))" : address
  }

  /// "USD Coin (USDC)", or just the symbol / name / address when some fields are missing.
  var displayName: String {
    let hasName = !(name ?? "").isEmpty
    let hasSymbol = !(symbol ?? "").isEmpty
    if hasName && hasSymbol { return "\(name!) (\(symbol!))" }
    if hasSymbol { return symbol! }
    if hasName { return name! }
    return displayAddress
  }
}
