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
      tokenStore: tokenStore
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
