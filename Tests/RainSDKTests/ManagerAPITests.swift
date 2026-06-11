import Testing
import Foundation
import PortalSwift
@testable import RainSDK

@Suite("Manager Public API Tests")
struct ManagerAPITests {

  // MARK: - buildTransactionParameters

  @Test("buildTransactionParameters returns a Rain-owned RainTransactionParameters; wires from, to, data; value is zero")
  func testComposeTransactionParameters() throws {
    let manager = RainSDKManager()

    // Rain-owned return type, not Portal's `ETHTransactionParam` (parity with Android).
    let params: RainTransactionParameters = manager.buildTransactionParameters(
      walletAddress: TestFixtures.walletAddress,
      contractAddress: TestFixtures.contractAddress,
      transactionData: "0xdeadbeef"
    )

    #expect(params.from == TestFixtures.walletAddress)
    #expect(params.to == TestFixtures.contractAddress)
    #expect(params.data == "0xdeadbeef")
    // value should be zero wei hex
    #expect(params.value == "0x0")
  }

  // MARK: - setWalletProvider

  @Test("setWalletProvider(nil) clears the provider")
  func testSetWalletProviderNilClearsProvider() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    // Sanity: provider is active.
    let addr = try await manager.getWalletAddress()
    #expect(addr == TestFixtures.walletAddress)

    manager.setWalletProvider(nil)

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getWalletAddress()
    }
  }

  @Test("setWalletProvider replaces an existing provider")
  func testSetWalletProviderReplaces() async throws {
    let (manager, _, _) = TestManagers.portalManager()

    let stub = StubWalletProvider()
    stub.addressToReturn = "0xreplaced000000000000000000000000000000000"
    manager.setWalletProvider(stub)

    let addr = try await manager.getWalletAddress()
    #expect(addr == "0xreplaced000000000000000000000000000000000")
  }

  // MARK: - reset

  @Test("reset() clears wallet provider so subsequent calls throw sdkNotInitialized")
  func testResetClearsWalletProvider() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    // Sanity: provider works.
    _ = try await manager.getWalletAddress()

    manager.reset()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getWalletAddress()
    }
  }

  @Test("reset() is idempotent")
  func testResetIdempotent() {
    let manager = RainSDKManager()
    manager.reset()
    manager.reset()
  }
}
