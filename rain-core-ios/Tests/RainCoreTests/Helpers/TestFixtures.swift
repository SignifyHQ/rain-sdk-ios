import Foundation
@testable import RainCore

// MARK: - Shared test fixtures

enum TestFixtures {
  static let walletAddress = "0x1234567890123456789012345678901234567890"
  static let contractAddress = "0x1234567890123456789012345678901234567890"
  static let proxyAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
  static let recipientAddress = "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc"
  static let tokenAddress = "0x9876543210987654321098765432109876543210"
  static let usdcAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

  /// 32-byte salt encoded as base64. Used by withdrawCollateral / estimateWithdrawalFee.
  static let validSaltBase64 = Data(repeating: 0xAA, count: 32).base64EncodedString()

  /// 65-byte signature encoded as hex with `0x` prefix.
  static let validSignatureHex = "0x" + String(repeating: "01", count: 65)

  static var defaultWithdrawAddresses: WithdrawAssetAddresses {
    WithdrawAssetAddresses(
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
  }

  static var defaultEIP712Addresses: EIP712AssetAddresses {
    EIP712AssetAddresses(
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
  }

  static func configs(
    chainId: Int = 1,
    rpcUrl: String = "https://mainnet.infura.io/v3/test"
  ) -> [NetworkConfig] {
    [NetworkConfig.testConfig(chainId: chainId, rpcUrl: rpcUrl)]
  }
}

// MARK: - Manager factories
//
// The monolith's `RainSDKManager()` + `initialize*`/`setWalletProvider` lifecycle no longer
// exists. A `RainSdkManager` (the concrete `RainClient`) is now always constructed already bound
// to a resolved `RainWalletProvider`. These factories build a manager directly around a stub or a
// Turnkey adapter — the same seam the registry uses when resolving a provider.

enum TestManagers {
  /// Returns a manager backed by a Turnkey mock context and a mock transaction builder.
  static func turnkeyManager(
    turnkey: MockTurnkey? = nil,
    builder: MockTransactionBuilderService? = nil,
    configs: [NetworkConfig] = TestFixtures.configs(),
    walletAddress: String? = nil
  ) -> (RainSdkManager, MockTurnkey, MockTransactionBuilderService) {
    let resolvedTurnkey = turnkey ?? MockTurnkey()
    let resolvedBuilder = builder ?? MockTransactionBuilderService(networkConfigs: configs)
    let tokenStore = TokenMetadataStore(chainReader: EVMChainReader(networkConfigs: configs))
    let adapter = TurnkeyWalletProviderAdapter(
      turnkey: resolvedTurnkey,
      transactionBuilder: resolvedBuilder,
      networkConfigs: configs,
      walletAddress: walletAddress,
      tokenStore: tokenStore
    )
    let manager = RainSdkManager(
      walletProvider: adapter,
      networkConfigs: configs,
      transactionBuilder: resolvedBuilder,
      tokenStore: tokenStore,
      providerId: .turnkey,
      capabilities: [.multiChain, .biometricGate]
    )
    return (manager, resolvedTurnkey, resolvedBuilder)
  }

  /// Returns a manager bound to a `StubWalletProvider`. The returned stub is mutable — tests
  /// configure return values on it.
  static func stubProviderManager(
    configs: [NetworkConfig] = TestFixtures.configs()
  ) async throws -> (RainSdkManager, StubWalletProvider) {
    let stub = StubWalletProvider()
    let builder = MockTransactionBuilderService(networkConfigs: configs)
    let tokenStore = TokenMetadataStore(chainReader: EVMChainReader(networkConfigs: configs))
    let manager = RainSdkManager(
      walletProvider: stub,
      networkConfigs: configs,
      transactionBuilder: builder,
      tokenStore: tokenStore,
      providerId: ProviderId("stub"),
      capabilities: []
    )
    return (manager, stub)
  }
}
