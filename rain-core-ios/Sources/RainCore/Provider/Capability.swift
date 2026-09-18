import Foundation

/// Optional wallet-provider capabilities. Core negotiates behaviour against this set so it can
/// degrade gracefully instead of assuming every provider can do everything.
///
/// Design discipline (per the modular architecture proposal): prefer expressing a new provider
/// need as an optional `Capability` over widening the `WalletProvider` port with a new
/// required method. A bloated port re-couples every provider.
public enum Capability: String, Sendable, CaseIterable, Codable {
  /// Provider can export the private key / seed.
  case export
  /// Provider supports account recovery (e.g. Portal MPC backup / recover).
  case recovery
  /// Provider manages more than one chain family (e.g. Turnkey EVM + Solana).
  case multiChain
  /// Provider gates signing behind a biometric / passkey prompt.
  case biometricGate
  /// The provider's sends are fee-sponsored — a third party pays the network fee — so core skips
  /// the self-paid preflights that would charge the fee to the wallet (the Solana fee-lamport
  /// check and dry run). Fee estimates still quote the on-chain cost — what the user saves.
  /// Core's operative, per-chain check is
  /// `WalletProvider.sponsorsFees(chainId:)`; a provider sponsors only where it can broadcast.
  case gasSponsorship
}
