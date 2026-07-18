import Foundation

/// Optional wallet-provider capabilities. Core negotiates behaviour against this set so it can
/// degrade gracefully instead of assuming every provider can do everything.
///
/// Design discipline (per the modular architecture proposal): prefer expressing a new provider
/// need as an optional `Capability` over widening the `RainWalletProvider` port with a new
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
}
