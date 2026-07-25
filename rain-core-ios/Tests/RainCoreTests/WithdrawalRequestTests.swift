import Testing
import Foundation
import Web3
@testable import RainCore

/// Covers the withdrawal request contract: the caller's nonce reaches the signed EIP-712 payload,
/// and parameters that cannot produce a valid transaction are rejected before any network call.
@Suite("Withdrawal Request Tests")
struct WithdrawalRequestTests {

  // MARK: - Nonce threading

  @Test("withdrawCollateral signs the caller-supplied nonce instead of re-reading the chain")
  func testWithdrawCollateralUsesProvidedNonce() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.sendTransactionStatusQueue = [.broadcasted(hash: "0x" + String(repeating: "7", count: 64))]

    let (manager, _, builder) = TestManagers.turnkeyManager(turnkey: mockTurnkey)
    // A different value from the caller's, so a regression that ignores the argument is visible.
    builder.mockNonce = BigUInt(42)

    _ = try await manager.withdrawCollateral(
      chainId: 1,
      assetAddresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.0,
      decimals: 18,
      salt: TestFixtures.validSaltBase64,
      signature: TestFixtures.validSignatureHex,
      expiresAt: "1735689600",
      nonce: BigUInt(7)
    )

    #expect(builder.capturedEIP712Nonce == BigUInt(7))
    #expect(builder.getLatestNonceCallCount == 0)
  }

  @Test("withdrawCollateral reads the nonce from the chain when the caller passes nil")
  func testWithdrawCollateralFallsBackToChainNonce() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.sendTransactionStatusQueue = [.broadcasted(hash: "0x" + String(repeating: "7", count: 64))]

    let (manager, _, builder) = TestManagers.turnkeyManager(turnkey: mockTurnkey)
    builder.mockNonce = BigUInt(42)

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

    #expect(builder.capturedEIP712Nonce == BigUInt(42))
    #expect(builder.getLatestNonceCallCount == 1)
  }

  // MARK: - Parameter validation

  @Test("withdrawCollateral rejects a non-positive chainId")
  func testWithdrawCollateralRejectsNonPositiveChainId() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()

    await #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "")) {
      _ = try await manager.withdrawCollateral(
        chainId: 0,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: nil
      )
    }
    #expect(stub.sendTransactionCalls.isEmpty)
  }

  @Test("withdrawCollateral rejects a zero or negative amount")
  func testWithdrawCollateralRejectsNonPositiveAmount() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()

    for amount in [Decimal(0), Decimal(-1)] {
      await #expect(throws: RainSDKError.self) {
        _ = try await manager.withdrawCollateral(
          chainId: 1,
          assetAddresses: TestFixtures.defaultWithdrawAddresses,
          amount: amount,
          decimals: 18,
          salt: TestFixtures.validSaltBase64,
          signature: TestFixtures.validSignatureHex,
          expiresAt: "1735689600",
          nonce: nil
        )
      }
    }
    #expect(stub.sendTransactionCalls.isEmpty)
  }

  @Test("withdrawCollateral rejects negative decimals")
  func testWithdrawCollateralRejectsNegativeDecimals() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()

    await #expect(throws: RainSDKError.self) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: -1,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: nil
      )
    }
    #expect(stub.sendTransactionCalls.isEmpty)
  }

  @Test("estimateWithdrawalFee applies the same validation as withdrawCollateral")
  func testEstimateWithdrawalFeeValidatesParameters() async throws {
    let (manager, _) = try await TestManagers.stubProviderManager()

    await #expect(throws: RainSDKError.invalidConfig(chainId: -1, rpcUrl: "")) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: -1,
        addresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600"
      )
    }

    await #expect(throws: RainSDKError.self) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: TestFixtures.defaultWithdrawAddresses,
        amount: 0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600"
      )
    }
  }

  // MARK: - Helpers

  private func stubSendTransactionRPCs() {
    MockURLProtocol.stub(method: "eth_getTransactionCount", result: "0x1")
    MockURLProtocol.stub(method: "eth_estimateGas", result: "0x5208")  // 21000
    MockURLProtocol.stub(method: "eth_gasPrice", result: "0x4a817c800") // 20 gwei
  }
}
