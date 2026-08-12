import Testing
import Foundation
@testable import RainCore

/// Builder-level contract for the trusted Auth Pull configuration: which configurations `build()`
/// accepts, and which chains the resulting SDK will actually approve on.
@Suite("Auth Pull Config Tests")
struct RainAuthPullConfigTests {

  private let operatorAddress = TestFixtures.authPullOperator

  private func configs(_ chainIds: [Int]) -> [NetworkConfig] {
    chainIds.map { NetworkConfig.testConfig(chainId: $0, rpcUrl: "https://rpc.example/\($0)") }
  }

  // MARK: - Accepted configurations

  @Test("a sandbox config with one configured RPC builds")
  func sandboxConfigBuilds() throws {
    _ = try RainSdk.builder()
      .rpcEndpoints(configs([RainChain.baseSepolia]))
      .authPullConfig(.sandbox(operatorAddress: operatorAddress))
      .build()
  }

  @Test("the canonical token addresses are the ones Rain publishes")
  func canonicalTokenAddresses() {
    let sandbox = RainAuthPullConfig.sandbox(operatorAddress: operatorAddress)
    #expect(
      sandbox.tokenAddresses[RainChain.baseSepolia] == "0x036CbD53842c5426634e7929541eC2318f3dCF7e"
    )
    #expect(
      sandbox.tokenAddresses[RainChain.arbitrumSepolia] == "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d"
    )

    let production = RainAuthPullConfig.production(operatorAddress: operatorAddress)
    #expect(
      production.tokenAddresses[RainChain.baseMainnet] == "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"
    )
    #expect(
      production.tokenAddresses[RainChain.arbitrumMainnet] == "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"
    )
  }

  // MARK: - The resolved chain set

  /// The set the approval guard enforces, which is not the environment's set: a sandbox config
  /// covers two chains, but only the one with an RPC endpoint can carry an approval.
  @Test("the resolved chain set is the config narrowed to chains with an RPC")
  func resolvedSetIsNarrowedByRpc() throws {
    let rain = try RainSdk.builder()
      .rpcEndpoints(configs([RainChain.baseSepolia]))
      .authPullConfig(.sandbox(operatorAddress: operatorAddress))
      .build()

    #expect(rain.authPullChainIds == [RainChain.baseSepolia])
    // The environment's set is the wider answer, and the one a host must not gate UI on.
    #expect(RainAuthPullChains.supported(for: .dev).contains(RainChain.arbitrumSepolia))
  }

  @Test("every configured chain with an RPC is resolved, and nothing else")
  func resolvedSetCoversConfiguredChains() throws {
    let rain = try RainSdk.builder()
      .rpcEndpoints(
        configs([
          RainChain.baseSepolia,
          RainChain.arbitrumSepolia,
          // An unrelated chain must not leak into the Auth Pull set.
          RainChain.avalancheTestnet,
        ])
      )
      .authPullConfig(.sandbox(operatorAddress: operatorAddress))
      .build()

    #expect(rain.authPullChainIds == [RainChain.baseSepolia, RainChain.arbitrumSepolia])
  }

  /// No `authPullConfig(_:)` means Auth Pull is off, and the set has to say so.
  @Test("an unconfigured SDK resolves no Auth Pull chains")
  func unconfiguredResolvesNothing() throws {
    let rain = try RainSdk.builder()
      .rpcEndpoints(configs([RainChain.baseSepolia]))
      .build()

    #expect(rain.authPullChainIds.isEmpty)
  }

  /// The case the environment set cannot answer at all: `supported(for: .custom)` is empty by
  /// design, so a custom gateway's own chains are only discoverable through the resolved set.
  @Test("a custom gateway can enumerate the chains it configured")
  func customGatewayEnumeratesItsChains() throws {
    let url = try #require(URL(string: "https://rain.example"))
    let rain = try RainSdk.builder()
      .rpcEndpoints(configs([RainChain.baseSepolia, RainChain.arbitrumSepolia]))
      .rainApiEnvironment(.custom(url))
      .authPullConfig(
        .custom(
          operatorAddress: operatorAddress,
          tokenAddresses: [
            RainChain.arbitrumSepolia: "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d"
          ]
        )
      )
      .build()

    #expect(rain.authPullChainIds == [RainChain.arbitrumSepolia])
    #expect(RainAuthPullChains.supported(for: .custom(url)).isEmpty)
  }

  // MARK: - Rejected configurations

  @Test("a production config is rejected in the dev environment")
  func productionConfigRejectedInDev() throws {
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.baseMainnet, RainChain.arbitrumMainnet]))
        .authPullConfig(.production(operatorAddress: operatorAddress))
        .build()
    }
  }

  @Test("a sandbox config is rejected in the production environment")
  func sandboxConfigRejectedInProduction() throws {
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.baseSepolia]))
        .rainApiEnvironment(.production)
        .authPullConfig(.sandbox(operatorAddress: operatorAddress))
        .build()
    }
  }

  @Test("a custom environment requires explicit custom targets")
  func customRequiresCustomTargets() throws {
    let url = try #require(URL(string: "https://rain.example"))
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.baseSepolia, RainChain.arbitrumSepolia]))
        .rainApiEnvironment(.custom(url))
        .authPullConfig(.sandbox(operatorAddress: operatorAddress))
        .build()
    }
  }

  @Test("a malformed operator address is rejected")
  func malformedOperatorRejected() throws {
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.baseSepolia]))
        .authPullConfig(.sandbox(operatorAddress: "0xnope"))
        .build()
    }
  }

  /// Syntactically valid, and approving it grants a spend allowance to nobody: a silent no-op that
  /// looks like a successful setup.
  @Test("the zero address is rejected as an operator")
  func zeroOperatorRejected() throws {
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.baseSepolia]))
        .authPullConfig(
          .sandbox(operatorAddress: "0x0000000000000000000000000000000000000000")
        )
        .build()
    }
  }

  @Test("an empty token map is rejected")
  func emptyTokenMapRejected() throws {
    let url = try #require(URL(string: "https://rain.example"))
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.baseSepolia]))
        .rainApiEnvironment(.custom(url))
        .authPullConfig(.custom(operatorAddress: operatorAddress, tokenAddresses: [:]))
        .build()
    }
  }

  @Test("a malformed or zero token contract is rejected")
  func malformedTokenRejected() throws {
    let url = try #require(URL(string: "https://rain.example"))
    for token in ["0xnope", "0x0000000000000000000000000000000000000000"] {
      #expect(throws: RainSDKError.invalidConfig(details: "")) {
        _ = try RainSdk.builder()
          .rpcEndpoints(configs([RainChain.baseSepolia]))
          .rainApiEnvironment(.custom(url))
          .authPullConfig(
            .custom(
              operatorAddress: operatorAddress,
              tokenAddresses: [RainChain.baseSepolia: token]
            )
          )
          .build()
      }
    }
  }

  /// A custom gateway may front either environment, but not a chain Auth Pull does not run on.
  @Test("a chain outside the known Auth Pull sets is rejected")
  func unknownChainRejected() throws {
    let url = try #require(URL(string: "https://rain.example"))
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.avalancheTestnet]))
        .rainApiEnvironment(.custom(url))
        .authPullConfig(
          .custom(
            operatorAddress: operatorAddress,
            tokenAddresses: [RainChain.avalancheTestnet: TestFixtures.authPullUsdcAddress]
          )
        )
        .build()
    }
  }

  /// Without an endpoint there is no chain to read the allowance on or send the approval over, so
  /// the configuration could never do anything.
  @Test("a config whose chains all lack an RPC endpoint is rejected")
  func noRpcForAnyTrustedChainRejected() throws {
    #expect(throws: RainSDKError.invalidConfig(details: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints(configs([RainChain.avalancheTestnet]))
        .authPullConfig(.sandbox(operatorAddress: operatorAddress))
        .build()
    }
  }
}
