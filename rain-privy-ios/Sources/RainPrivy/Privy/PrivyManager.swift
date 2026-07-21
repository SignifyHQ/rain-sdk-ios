import Foundation
import PrivySDK
import RainCore

/// Wrapper around the Privy SDK encapsulating all Privy interactions — the custody seam.
///
/// Privy owns signing and broadcasting via its EIP-1193 embedded-wallet provider; balance / fee
/// reads run through ``PrivyRpcClient`` instead. Authentication and `PrivySdk.initialize(...)`
/// happen in the host app, so this only ever consumes an already-authenticated `Privy` singleton.
///
/// An `actor` for two reasons:
///  1. **Race-safe address resolution** — concurrent first-access callers share a single
///     in-flight resolution.
///  2. **Serialized sends** — Privy's provider is stateful about the active chain
///     (`switchChain` mutates it before `request` broadcasts), and actors are re-entrant at
///     `await` points, so the switch+broadcast pair runs under an explicit async lock.
actor PrivyManager {
  private let source: any PrivyWalletSource

  /// Once resolved, the embedded-wallet address is stable for the manager's lifetime.
  private var cachedAddress: String?
  /// In-flight resolution shared by concurrent first callers (resolve-once).
  private var addressResolution: Task<String, Error>?

  // MARK: async lock (send serialization)
  private var sendLocked = false
  private var sendWaiters: [CheckedContinuation<Void, Never>] = []

  init(source: any PrivyWalletSource) {
    self.source = source
  }

  init(privy: any Privy) {
    self.init(source: LivePrivyWalletSource(privy: privy))
  }

  // MARK: - Address

  /// The signing wallet's address, resolved once and cached. `override` (when non-empty) wins and
  /// is returned without a Privy round-trip.
  func address(override: String?) async throws -> String {
    if let override, !override.isEmpty {
      return override
    }
    if let cachedAddress {
      return cachedAddress
    }
    if let addressResolution {
      return try await addressResolution.value
    }
    let task = Task { [source] in
      try await Self.resolveWallet(source: source, override: nil).address
    }
    addressResolution = task
    do {
      let resolved = try await task.value
      cachedAddress = resolved
      return resolved
    } catch {
      // Allow a later caller to retry (e.g. wallet created after this failed probe).
      addressResolution = nil
      throw error
    }
  }

  // MARK: - Sign

  /// Signs EIP-712 typed data via `eth_signTypedData_v4`. Returns the 0x-prefixed signature.
  /// Signing takes no chain state, so it is not serialized with sends.
  func signTypedData(walletAddress: String, typedDataJson: String) async throws -> String {
    let wallet = try await Self.resolveWallet(source: source, override: walletAddress)
    let rpcRequest = EthereumRpcRequest(
      method: "eth_signTypedData_v4",
      params: [wallet.address, typedDataJson]
    )
    return try await request(wallet: wallet, rpcRequest)
  }

  // MARK: - Send

  /// Broadcasts a transaction via `eth_sendTransaction`, returning the tx hash. Points Privy at
  /// Rain's configured RPC for `chainId` via `switchChain` first; the wallet fills any omitted
  /// gas / nonce. The switch + broadcast run under the async lock so concurrent sends serialize.
  func sendTransaction(
    walletAddress: String,
    rpcUrl: String,
    chainId: Int,
    transaction: EthereumRpcRequest.UnsignedEthTransaction
  ) async throws -> String {
    let wallet = try await Self.resolveWallet(source: source, override: walletAddress)
    let rpcRequest = try EthereumRpcRequest.ethSendTransaction(transaction: transaction)

    await acquireSendLock()
    do {
      await wallet.switchChain(chainId: chainId, rpcUrl: rpcUrl)
      let hash = try await request(wallet: wallet, rpcRequest)
      releaseSendLock()
      return hash
    } catch {
      releaseSendLock()
      throw error
    }
  }

  // MARK: - Transactions

  /// Fetches one page of transaction history for the signing wallet via Privy's indexer.
  ///
  /// Failures bubble up raw for the same reason as ``request(wallet:_:)``: pre-wrapping would
  /// bypass error mapping downstream.
  func getTransactions(
    walletAddress: String?,
    params: GetTransactionsParams
  ) async throws -> PrivyTransactionsPage {
    let wallet = try await Self.resolveWallet(source: source, override: walletAddress)
    return try await wallet.getTransactions(params)
  }

  // MARK: - Internals

  /// Issues an RPC request through the wallet's provider.
  ///
  /// Failures bubble up raw (only logged here): `RainSDKError.from(underlying:)` short-circuits
  /// on any `RainSDKError`, so pre-wrapping would bypass ``PrivyErrorMapping`` and hide
  /// user-rejection / insufficient-funds behind a generic `.providerError`.
  /// `CancellationError` is rethrown as-is.
  private func request(
    wallet: any PrivyEthereumSigner,
    _ rpcRequest: EthereumRpcRequest
  ) async throws -> String {
    do {
      return try await wallet.request(rpcRequest)
    } catch {
      if error is CancellationError { throw error }
      RainLogger.error("Rain SDK: Privy RPC request failed for \(rpcRequest.method): \(error)")
      throw error
    }
  }

  /// Resolves the embedded Ethereum wallet to sign with. Uses `override` when supplied, otherwise
  /// the user's first embedded Ethereum wallet.
  private static func resolveWallet(
    source: any PrivyWalletSource,
    override: String?
  ) async throws -> any PrivyEthereumSigner {
    guard let wallets = await source.embeddedEthereumWallets() else {
      throw RainSDKError.tokenExpired
    }
    guard !wallets.isEmpty else {
      throw RainSDKError.walletUnavailable
    }
    guard let override, !override.isEmpty else {
      return wallets[0]
    }
    guard let match = wallets.first(where: {
      $0.address.caseInsensitiveCompare(override) == .orderedSame
    }) else {
      throw RainSDKError.walletUnavailable
    }
    return match
  }

  // MARK: - Async lock

  /// Acquires the send lock, suspending until it is free (fair FIFO).
  private func acquireSendLock() async {
    if !sendLocked {
      sendLocked = true
      return
    }
    await withCheckedContinuation { continuation in
      sendWaiters.append(continuation)
    }
  }

  /// Releases the send lock, handing it to the next waiter (if any).
  private func releaseSendLock() {
    if sendWaiters.isEmpty {
      sendLocked = false
    } else {
      sendWaiters.removeFirst().resume()
    }
  }
}
