import Foundation

/// The chains Rain's Auth Pull runs on, grouped by environment.
///
/// Rain's operator address and USDC contract both differ between sandbox and production, and the
/// two sets of chains do not overlap. Approving on a chain from the wrong environment therefore
/// produces a perfectly valid allowance that no authorization will ever draw on — and on a mainnet
/// chain it spends real gas to grant a real spend allowance to an address Rain does not use there.
/// The approval path rejects that pairing up front (see `RainSdkManager+Approvals`).
///
/// This answers for an *environment*. What a built SDK will actually accept is narrower — the
/// host's ``RainAuthPullConfig`` intersected with the chains that have an RPC endpoint — and is
/// exposed as ``RainSdk/authPullChainIds`` / ``RainClient/authPullChainIds``. Gate UI on those;
/// reach for ``supported(for:)`` only before an SDK exists, and never keep a third copy of the
/// list, which is how these drift apart.
///
/// **Maintenance**
/// In-tree like `TokenRegistry`, so the SDK owns updates. Rain is actively adding chains to the
/// beta; edit this file and ship a release. The matching USDC entries live in `TokenRegistry`, and
/// `RainAuthPullChainsTests` enforces that every chain here has one.
public enum RainAuthPullChains {
  /// Sandbox Auth Pull chains.
  public static let sandbox: Set<Int> = [
    RainChain.baseSepolia,
    RainChain.arbitrumSepolia,
  ]

  /// Production Auth Pull chains.
  public static let production: Set<Int> = [
    RainChain.baseMainnet,
    RainChain.arbitrumMainnet,
  ]

  /// The Auth Pull chains for `environment`.
  ///
  /// `.dev` maps to Rain's sandbox set: Rain documents the operator per *sandbox* / *production*,
  /// and `api-dev.rain.xyz` is the sandbox-side host. A `.custom` base URL cannot safely imply an
  /// environment, so it fails closed. Custom gateways opt in through an explicit
  /// ``RainAuthPullConfig``.
  public static func supported(for environment: RainApiEnvironment) -> Set<Int> {
    switch environment {
    case .dev: return sandbox
    case .production: return production
    case .custom: return []
    }
  }

  /// Whether `chainId` is an Auth Pull chain in `environment`.
  public static func isSupported(chainId: Int, in environment: RainApiEnvironment) -> Bool {
    supported(for: environment).contains(chainId)
  }
}
