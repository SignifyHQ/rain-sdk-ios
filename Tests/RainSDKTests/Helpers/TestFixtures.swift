import Foundation
import PortalSwift
@testable import RainSDK

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

enum TestManagers {
  /// Returns a manager backed by a Portal mock and a mock transaction builder.
  static func portalManager(
    portal: MockPortal? = nil,
    builder: MockTransactionBuilderService? = nil,
    configs: [NetworkConfig] = TestFixtures.configs()
  ) -> (RainSDKManager, MockPortal, MockTransactionBuilderService) {
    let resolvedPortal = portal ?? {
      let p = MockPortal()
      p.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
      return p
    }()
    let resolvedBuilder = builder ?? MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: resolvedPortal, transactionBuilder: resolvedBuilder)
    return (manager, resolvedPortal, resolvedBuilder)
  }

  /// Returns a manager backed by a Turnkey mock context and a mock transaction builder.
  static func turnkeyManager(
    turnkey: MockTurnkey? = nil,
    builder: MockTransactionBuilderService? = nil,
    configs: [NetworkConfig] = TestFixtures.configs(),
    walletAddress: String? = nil
  ) -> (RainSDKManager, MockTurnkey, MockTransactionBuilderService) {
    let resolvedTurnkey = turnkey ?? MockTurnkey()
    let resolvedBuilder = builder ?? MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(
      turnkey: resolvedTurnkey,
      transactionBuilder: resolvedBuilder,
      networkConfigs: configs,
      walletAddress: walletAddress
    )
    return (manager, resolvedTurnkey, resolvedBuilder)
  }

  /// Returns a manager initialized in wallet-agnostic mode.
  static func walletAgnosticManager(
    configs: [NetworkConfig] = TestFixtures.configs()
  ) async throws -> RainSDKManager {
    let manager = RainSDKManager()
    try await manager.initialize(networkConfigs: configs)
    return manager
  }
}
