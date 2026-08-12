import Foundation
import RainCore

/// Which Rain environment this build of the demo talks to.
///
/// One constant drives three things that have to agree: the Rain API host, the chains the picker
/// offers, and the operator address the Auth Pull screen prefills. The SDK rejects an Auth Pull
/// approval on a chain outside the configured environment's set, so they cannot be set separately.
///
/// Left on `.dev` deliberately. `.production` means mainnet: real USDC, real gas, and an allowance
/// a real card authorization can draw on.
enum SampleEnvironment {
  static let rainApi: RainApiEnvironment = .dev

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
    case .dev, .custom:
      return "0x5a6E6b0d5Ea051CfFF9b3dcC2Aa8Dac226458f29"
    }
  }

  /// The trusted targets the SDK is built with. Auth Pull is refused entirely without this, and
  /// then accepts only this operator and the canonical token for each chain.
  static var authPullConfig: RainAuthPullConfig {
    switch rainApi {
    case .production:
      return .production(operatorAddress: authPullOperator)
    case .dev:
      return .sandbox(operatorAddress: authPullOperator)
    case .custom:
      // A gateway URL implies neither environment, so there is nothing to infer from here.
      preconditionFailure(
        "Custom Rain environments require an explicit Auth Pull chain/token configuration"
      )
    }
  }

  static var isProduction: Bool {
    if case .production = rainApi { return true }
    return false
  }

  /// A human label for the mode banner, so it is obvious which environment a build is pointed at.
  static var displayName: String {
    switch rainApi {
    case .dev: return "Sandbox"
    case .production: return "Production"
    case .custom: return "Custom"
    }
  }
}
