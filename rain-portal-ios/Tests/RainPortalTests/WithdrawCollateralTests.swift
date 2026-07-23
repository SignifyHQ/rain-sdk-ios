import Testing
import Foundation
import PortalSwift
import Web3
@testable import RainCore
@testable import RainPortal

/// Manager-contract tests for withdrawCollateral / estimateWithdrawalFee: error wrapping, input
/// parsing. The removed init/lifecycle cases ("throws sdkNotInitialized before initialization" and
/// "after wallet-agnostic initialize") are dropped.
@Suite("Withdraw Collateral Tests")
struct WithdrawCollateralTests {

  // MARK: - withdrawCollateral

  @Test("withdrawCollateral throws walletUnavailable when Portal has no address")
  func testWithdrawCollateralNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }

  @Test("withdrawCollateral propagates invalidConfig when chainId is unknown and nonce is nil")
  func testWithdrawCollateralInvalidChainId() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    // Real builder to exercise the invalidConfig branch when fetching the nonce for an unknown chain.
    let configs = TestFixtures.configs()
    let tokenStore = TokenMetadataStore(chainReader: EVMChainReader(networkConfigs: configs))
    let adapter = PortalWalletProviderAdapter(portal: mockPortal, tokenStore: tokenStore)
    let manager = RainSdkManager(
      walletProvider: adapter,
      networkConfigs: configs,
      transactionBuilder: TransactionBuilderService(networkConfigs: configs),
      tokenStore: tokenStore,
      providerId: .portal,
      capabilities: [.export, .recovery]
    )

    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      _ = try await manager.withdrawCollateral(
        chainId: 999,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }

  @Test("withdrawCollateral translates a simulation revert into withdrawalRevertedByNetwork")
  func testWithdrawCollateralRevertMapsToWithdrawalReverted() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    // The adapter's eth_call preflight wraps this into .transactionSimulationFailed; on the
    // withdrawal path core re-classifies that as RAIN_405.
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      error: NSError(domain: "PortalError", code: 3, userInfo: [NSLocalizedDescriptionKey: "execution reverted"])
    )
    let (manager, _, builder) = TestManagers.portalManager(portal: mockPortal)
    builder.mockNonce = BigUInt(42)

    await #expect(throws: RainSDKError.withdrawalRevertedByNetwork) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }

  // MARK: - estimateWithdrawalFee

  @Test("estimateWithdrawalFee throws walletUnavailable when Portal has no address")
  func testEstimateWithdrawalFeeNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, builder) = TestManagers.portalManager(portal: mockPortal)
    builder.mockNonce = BigUInt(1)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee translates a simulation revert into withdrawalRevertedByNetwork")
  func testEstimateWithdrawalFeeRevertMapsToWithdrawalReverted() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    // The error Portal's mapper produces for a PortalRpcError code 3 on eth_estimateGas
    // (PortalRpcError itself has no test-visible initializer); on the withdrawal path core
    // re-classifies it as RAIN_405.
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_estimateGas,
      error: RainSDKError.transactionSimulationFailed(
        underlying: NSError(domain: "PortalError", code: 3, userInfo: [NSLocalizedDescriptionKey: "execution reverted"])
      )
    )
    let (manager, _, builder) = TestManagers.portalManager(portal: mockPortal)
    builder.mockNonce = BigUInt(42)

    await #expect(throws: RainSDKError.withdrawalRevertedByNetwork) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee throws for invalid signature encoding")
  func testEstimateWithdrawalFeeInvalidSignature() async throws {
    let (manager, _, builder) = TestManagers.portalManager()
    builder.mockNonce = BigUInt(1)

    await #expect(throws: RainSDKError.internalLogicError(details: "Failed to convert withdrawal signature hex string to Data")) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: "invalid-base64!!!",
        expiresAt: "1735689600"
      )
    }
  }
}
