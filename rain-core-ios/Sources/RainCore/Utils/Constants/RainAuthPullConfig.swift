import Foundation

/// Trusted Auth Pull targets for one Rain environment.
///
/// Auth Pull approvals are intentionally disabled until a host supplies this configuration. The
/// SDK then requires every approval, allowance read, confirmation, and fee estimate to use this
/// exact operator and the configured token for the selected chain.
public struct RainAuthPullConfig: Sendable, Equatable {
  /// Rain's operator for the environment: the only spender an approval may name.
  public let operatorAddress: String

  /// The trusted token contract per Auth Pull chain: the only token an approval may target.
  public let tokenAddresses: [Int: String]

  /// Which environment this configuration is for, checked against the configured API host at
  /// `build()` so a sandbox config cannot be handed to a production SDK.
  internal let kind: Kind

  internal enum Kind: Sendable { case sandbox, production, custom }

  private init(operatorAddress: String, tokenAddresses: [Int: String], kind: Kind) {
    self.operatorAddress = operatorAddress
    self.tokenAddresses = tokenAddresses
    self.kind = kind
  }

  /// Canonical sandbox USDC contracts, with the operator supplied by Rain.
  public static func sandbox(operatorAddress: String) -> RainAuthPullConfig {
    RainAuthPullConfig(
      operatorAddress: operatorAddress,
      tokenAddresses: [
        RainChain.baseSepolia: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
        RainChain.arbitrumSepolia: "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d",
      ],
      kind: .sandbox
    )
  }

  /// Canonical production USDC contracts, with the operator supplied by Rain.
  public static func production(operatorAddress: String) -> RainAuthPullConfig {
    RainAuthPullConfig(
      operatorAddress: operatorAddress,
      tokenAddresses: [
        RainChain.baseMainnet: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
        RainChain.arbitrumMainnet: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
      ],
      kind: .production
    )
  }

  /// Explicit targets for a custom Rain API gateway. There is no safe environment inference from
  /// an arbitrary URL, so custom gateways must opt in with an exact chain/token map.
  public static func custom(
    operatorAddress: String,
    tokenAddresses: [Int: String]
  ) -> RainAuthPullConfig {
    RainAuthPullConfig(
      operatorAddress: operatorAddress,
      tokenAddresses: tokenAddresses,
      kind: .custom
    )
  }
}
