import Foundation
import RainCore

/// Which Rain environment this build of the demo talks to.
///
/// One constant drives three things that have to agree: the Rain API host the demo's own
/// `RainApiClient` calls, the chains the picker offers, and the operator address the Auth Pull
/// screen prefills. The SDK itself knows nothing about Rain environments — it only checks that
/// an Auth Pull config's chains belong to the environment its kind names.
///
/// Left on `.sandbox` deliberately. `.production` means mainnet: real USDC, real gas, and an
/// allowance a real card authorization can draw on.
enum SampleEnvironment {
  static let rainApi: RainApiEnvironment = .sandbox

  /// Rain's Auth Pull operator for ``rainApi`` — the spender an approval names, one address per
  /// environment and the same on every chain within it. Published in Rain's Auth Pull docs:
  /// https://docs.rain.xyz/docs/authorization-pull-from-user-wallet
  ///
  /// Shown on the Auth Pull screen so it is obvious which address is being approved. A host app
  /// should read this from Rain rather than shipping it as a constant, keyed off the same
  /// environment it configures the SDK with.
  static var authPullOperator: String {
    switch rainApi {
    case .production:
      return "0xA3750f692BB9Fc5e62834f9291E3D508d7Ba4F74"
    case .sandbox:
      return "0x5a6E6b0d5Ea051CfFF9b3dcC2Aa8Dac226458f29"
    }
  }

  /// The trusted targets the SDK is built with. Auth Pull is refused entirely without this, and
  /// then accepts only this operator and the canonical token for each chain.
  static var authPullConfig: RainAuthPullConfig {
    switch rainApi {
    case .production:
      return .production(operatorAddress: authPullOperator)
    case .sandbox:
      return .sandbox(operatorAddress: authPullOperator)
    }
  }

  static var isProduction: Bool { rainApi == .production }

  /// The Auth Pull chains for this environment — the picker's answer before any SDK exists.
  static var authPullChains: Set<Int> {
    isProduction ? RainAuthPullChains.production : RainAuthPullChains.sandbox
  }

  /// A human label for the mode banner, so it is obvious which environment a build is pointed at.
  static var displayName: String {
    isProduction ? "Production" : "Sandbox"
  }
}
