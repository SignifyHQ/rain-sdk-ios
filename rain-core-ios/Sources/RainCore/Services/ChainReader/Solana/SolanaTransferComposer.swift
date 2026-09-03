import Foundation
import Web3

/// An unsigned Solana transfer ready for a wallet provider to sign. Public so out-of-core adapters
/// (e.g. `RainPrivy`) can receive one through ``RainSolanaSupport``.
public struct UnsignedSolanaTransfer: Sendable {
  /// The serialized unsigned transaction — the bytes that were simulated, so callers sign these
  /// and not a rebuilt variant.
  public let transaction: Data
  public let recentBlockhash: String
  /// Whether the transfer also creates the recipient's token account (the sender pays its rent).
  public let createsRecipientAccount: Bool

  /// Lowercase hex of ``transaction`` — the encoding Turnkey's `sol_send_transaction` expects.
  public var transactionHex: String {
    SolanaTransactionBuilder.hexEncode([UInt8](transaction))
  }

  internal init(transaction: [UInt8], recentBlockhash: String, createsRecipientAccount: Bool = false) {
    self.transaction = Data(transaction)
    self.recentBlockhash = recentBlockhash
    self.createsRecipientAccount = createsRecipientAccount
  }
}

/// Composes unsigned Solana transfers, running every preflight the SDK requires before a wallet
/// provider signs: address validation, mint resolution, associated-token-account derivation and
/// creation, balance and fee checks, and a simulation dry run for SPL transfers. Providers only
/// sign and broadcast the result, so the checks cannot drift between them.
@_spi(RainAdapter) public struct SolanaTransferComposer: Sendable {
  /// Base fee for a single-signature Solana transaction.
  private static let feeLamports: UInt64 = 5_000
  /// Rent-exempt minimum for a 165-byte SPL token account (~0.00204 SOL), paid by the sender when
  /// a transfer has to create the recipient's account. Read from the chain it would be
  /// `getMinimumBalanceForRentExemption(165)`; this constant only gates a friendlier up-front
  /// error, and the transaction is simulated afterwards regardless.
  private static let tokenAccountRentLamports: UInt64 = 2_039_280

  private let rpcClient: SolanaRpcClient

  init(rpcClient: SolanaRpcClient) {
    self.rpcClient = rpcClient
  }

  /// A native SOL transfer. `amount` is converted exactly; sub-lamport precision is rejected
  /// rather than truncated.
  @_spi(RainAdapter) public func composeNative(
    chainId: Int,
    from fromAddress: String,
    to toAddress: String,
    amount: Decimal
  ) async throws -> UnsignedSolanaTransfer {
    guard amount >= 0 else {
      throw RainSDKError.invalidAmount(amount: "\(amount)", reason: "must not be negative")
    }
    let lamports = try Self.exactBaseUnits(
      amount: amount,
      decimals: SolanaConverter.solDecimals,
      unitLabel: "SOL"
    )
    let blockhash = try await rpcClient.getLatestBlockhash(chainId: chainId)
    let transaction = try SolanaTransactionBuilder.buildTransferBytes(
      from: fromAddress,
      to: toAddress,
      lamports: try Self.u64BaseUnits(lamports, amount: amount),
      recentBlockhash: blockhash
    )
    return UnsignedSolanaTransfer(transaction: transaction, recentBlockhash: blockhash)
  }

  /// An SPL transfer, creating the recipient's token account in the same transaction when they do
  /// not have one yet.
  ///
  /// Tokens live in per-mint *token accounts*, not in the wallet itself, so `toAddress` is the
  /// recipient's wallet and the account that actually receives the transfer is derived from it.
  /// Creating a missing recipient account costs the sender rent (~0.002 SOL).
  ///
  /// The mint is read from the chain first: its decimals scale `amount`, and the token program
  /// that owns it both receives the transfer and seeds the token-account derivation. The transfer
  /// is simulated against the cluster while still unsigned, so a failure surfaces as a typed error
  /// rather than as a broadcast that quietly fails on chain.
  @_spi(RainAdapter) public func composeSPLToken(
    chainId: Int,
    from fromAddress: String,
    mintAddress: String,
    to toAddress: String,
    amount: Decimal
  ) async throws -> UnsignedSolanaTransfer {
    try Self.validateAddress(fromAddress, label: "sender")
    try Self.validateAddress(toAddress, label: "recipient")
    try Self.validateAddress(mintAddress, label: "mint")
    guard fromAddress != toAddress else {
      throw RainSDKError.invalidRecipient(address: toAddress, reason: "the recipient is this wallet")
    }

    // Checked before scaling, so a negative amount reports what is actually wrong with it rather
    // than the decimal-places message scaling would produce.
    guard amount > 0 else {
      throw RainSDKError.invalidAmount(amount: "\(amount)", reason: "must be greater than zero")
    }
    guard let mint = try await rpcClient.getMintInfo(chainId: chainId, mint: mintAddress) else {
      throw RainSDKError.tokenNotFound(token: mintAddress, chainId: chainId)
    }
    let baseUnits = try Self.exactBaseUnits(
      amount: amount,
      decimals: mint.decimals,
      unitLabel: "this token"
    )

    // The recipient must be a wallet. Passing a token account instead would derive a token account
    // *of* a token account — a well-formed address nobody can spend from.
    if let recipientAccount = try await rpcClient.getAccountInfo(chainId: chainId, address: toAddress),
       SolanaPrograms.isTokenProgram(recipientAccount.ownerProgram) {
      throw RainSDKError.invalidRecipient(
        address: toAddress,
        reason: "this address belongs to a token program (a token account or a mint); "
          + "pass the recipient's wallet address instead"
      )
    }

    let source = try SolanaProgramAddress.associatedTokenAddress(
      owner: fromAddress, mint: mintAddress, tokenProgramId: mint.tokenProgramId
    )
    let destination = try SolanaProgramAddress.associatedTokenAddress(
      owner: toAddress, mint: mintAddress, tokenProgramId: mint.tokenProgramId
    )

    guard let sourceAccount = try await rpcClient.getTokenAccount(chainId: chainId, address: source)
    else {
      throw RainSDKError.tokenAccountNotFound(walletAddress: fromAddress, token: mintAddress)
    }
    guard sourceAccount.rawAmount >= baseUnits else {
      throw RainSDKError.insufficientTokenBalance(
        requested: "\(amount)",
        available: EthereumConverter
          .baseUnitsToDecimal(sourceAccount.rawAmount, decimals: mint.decimals)
          .description,
        token: mintAddress
      )
    }

    let createDestination = !(try await rpcClient.accountExists(chainId: chainId, address: destination))
    try await requireLamportsForFees(
      chainId: chainId, address: fromAddress, includeAccountRent: createDestination
    )

    let blockhash = try await rpcClient.getLatestBlockhash(chainId: chainId)
    let transaction = try SolanaTransactionBuilder.buildSPLTransferBytes(
      owner: fromAddress,
      source: source,
      destination: destination,
      destinationOwner: toAddress,
      mint: mintAddress,
      tokenProgramId: mint.tokenProgramId,
      amount: try Self.u64BaseUnits(baseUnits, amount: amount),
      decimals: UInt8(mint.decimals),
      recentBlockhash: blockhash,
      createDestinationAccount: createDestination
    )
    try await simulate(chainId: chainId, transaction: transaction)

    RainLogger.debug(
      """
      Rain SDK: sending \(baseUnits.description) of mint \(mintAddress) on chainId=\(chainId) \
      (creating recipient token account: \(createDestination))
      """
    )
    return UnsignedSolanaTransfer(
      transaction: transaction,
      recentBlockhash: blockhash,
      createsRecipientAccount: createDestination
    )
  }

  // MARK: - Preflight helpers

  /// Scales a human-readable `amount` to base units, rejecting anything finer than the unit can
  /// represent rather than silently truncating it.
  private static func exactBaseUnits(
    amount: Decimal,
    decimals: Int,
    unitLabel: String
  ) throws -> BigUInt {
    do {
      return try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    } catch {
      throw RainSDKError.invalidAmount(
        amount: "\(amount)",
        reason: "\(unitLabel) supports at most \(decimals) decimal places"
      )
    }
  }

  /// Narrows base units to the `UInt64` Solana instructions encode amounts in. A value past that
  /// width is rejected rather than truncated: truncation would send a *different* amount (often
  /// zero) that still simulates and broadcasts fine, which is worse than failing.
  private static func u64BaseUnits(_ baseUnits: BigUInt, amount: Decimal) throws -> UInt64 {
    guard let value = UInt64(baseUnits.description) else {
      throw RainSDKError.invalidAmount(
        amount: "\(amount)",
        reason: "is too large to encode — Solana amounts are 64-bit"
      )
    }
    return value
  }

  private static func validateAddress(_ address: String, label: String) throws {
    guard (try? Base58.decode(address))?.count == 32 else {
      throw RainSDKError.internalLogicError(details: "Invalid Solana \(label) address: \(address)")
    }
  }

  /// Fails early when the wallet cannot cover the network fee (plus token-account rent when the
  /// transfer has to create one). Simulation would catch this too, but only as an opaque program
  /// error — SOL for fees is a distinct problem from the token balance itself.
  private func requireLamportsForFees(
    chainId: Int,
    address: String,
    includeAccountRent: Bool
  ) async throws {
    let required = Self.feeLamports + (includeAccountRent ? Self.tokenAccountRentLamports : 0)
    let lamports = try await rpcClient.getBalanceLamports(chainId: chainId, address: address)
    guard lamports >= BigUInt(required.description) ?? 0 else {
      RainLogger.warning(
        "Rain SDK: wallet \(address) holds \(lamports) lamports, needs \(required) for this transfer"
      )
      throw RainSDKError.insufficientFunds(
        required: SolanaConverter.lamportsToSol(required).description,
        available: SolanaConverter.lamportsToSol(lamports).description
      )
    }
  }

  /// Dry-runs the unsigned transaction, translating a simulation failure into a typed error.
  private func simulate(chainId: Int, transaction: [UInt8]) async throws {
    let simulation = try await rpcClient.simulateTransaction(
      chainId: chainId,
      base64Transaction: Data(transaction).base64EncodedString()
    )
    guard !simulation.succeeded else { return }

    RainLogger.error(
      """
      Rain SDK: Solana transaction simulation failed: \(simulation.error ?? "unknown"); \
      logs: \(simulation.logs.joined(separator: " | "))
      """
    )
    throw RainSDKError.transactionSimulationFailed(
      underlying: RainSDKError.internalLogicError(
        details: simulation.error ?? "Solana transaction simulation failed"
      )
    )
  }
}
