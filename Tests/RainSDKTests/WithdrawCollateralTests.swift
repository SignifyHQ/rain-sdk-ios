import Testing
import Foundation
import PortalSwift
import Web3
@testable import RainSDK

/// Manager-contract tests for withdrawCollateral / estimateWithdrawalFee: validation, mode
/// guards, error wrapping, input parsing. Provider-specific flows live in `Adapters/`.
@Suite("Withdraw Collateral Tests")
struct WithdrawCollateralTests {

  // MARK: - withdrawCollateral

  @Test("withdrawCollateral throws sdkNotInitialized before initialization")
  func testWithdrawCollateralBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
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

  @Test("withdrawCollateral throws sdkNotInitialized after wallet-agnostic initialize")
  func testWithdrawCollateralAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
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
    // Real builder to exercise the invalidConfig branch when fetching nonce
    let realBuilder = TransactionBuilderService(networkConfigs: TestFixtures.configs())
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: realBuilder)

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

  @Test("estimateWithdrawalFee throws sdkNotInitialized before initialization")
  func testEstimateWithdrawalFeeBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
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

  @Test("estimateWithdrawalFee throws sdkNotInitialized after wallet-agnostic initialize")
  func testEstimateWithdrawalFeeAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
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
