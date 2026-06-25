import Testing
import Foundation
import CoreGraphics
@testable import PortalSwift
@testable import RainSDK

/// Manager-contract tests for wallet info APIs: validation and QR-code generation
/// (provider-independent). Provider-specific transaction-mapping tests live in `Adapters/`.
@Suite("Wallet Information Tests")
struct WalletInformationTests {

  // MARK: - getWalletAddress

  @Test("getWalletAddress throws sdkNotInitialized before initialization")
  func testGetWalletAddressBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getWalletAddress()
    }
  }

  @Test("getWalletAddress returns address when provider has one")
  func testGetWalletAddressSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)
    let address = try await manager.getWalletAddress()
    #expect(address == TestFixtures.walletAddress)
  }

  // MARK: - generateWalletAddressQRCode

  @Test("generateWalletAddressQRCode throws sdkNotInitialized when no provider")
  func testGenerateQRCodeNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.generateWalletAddressQRCode(dimension: 256)
    }
  }

  @Test("generateWalletAddressQRCode returns valid PNG data")
  func testGenerateQRCodeSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let imageData = try await manager.generateWalletAddressQRCode(dimension: 256)
    expectPNG(imageData)
  }

  @Test("generateWalletAddressQRCode honors custom dimension")
  func testGenerateQRCodeCustomDimension() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0xabcdef1234567890", forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let imageData = try await manager.generateWalletAddressQRCode(dimension: 128)
    expectPNG(imageData)
  }

  @Test("generateWalletAddressQRCode honors custom colors")
  func testGenerateQRCodeCustomColors() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let bg = CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    let fg = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    let imageData = try await manager.generateWalletAddressQRCode(
      dimension: 200,
      backgroundColor: bg,
      foregroundColor: fg
    )
    expectPNG(imageData)
  }

  // MARK: - getTransactions

  @Test("getTransactions throws sdkNotInitialized when no provider")
  func testGetTransactionsNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getTransactions(chainId: 1)
    }
  }

  @Test("getTransactions returns empty list when provider returns no transactions")
  func testGetTransactionsEmpty() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.mockFetchedTransactions = []
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let list = try await manager.getTransactions(chainId: 1)
    #expect(list.isEmpty)
  }

  @Test("getTransactions forwards pagination/order to the provider and returns its list")
  func testGetTransactionsRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let tx = WalletTransaction(
      blockNum: "100",
      uniqueId: "uid-1",
      hash: "0xabc",
      from: "0xfrom",
      to: "0xto",
      value: 1.0,
      erc721TokenId: nil,
      erc1155Metadata: nil,
      tokenId: nil,
      asset: nil,
      category: "external",
      rawContract: nil,
      metadata: WalletTransaction.Metadata(blockTimestamp: "2024-01-01T00:00:00Z"),
      chainId: 1
    )
    stub.transactionsToReturn = [tx]

    let list = try await manager.getTransactions(chainId: 1, limit: 5, offset: 2, order: .ASC)

    #expect(list.count == 1)
    #expect(list[0].hash == "0xabc")
    #expect(stub.getTransactionsCalls.count == 1)
    #expect(stub.getTransactionsCalls[0].chainId == 1)
    #expect(stub.getTransactionsCalls[0].limit == 5)
    #expect(stub.getTransactionsCalls[0].offset == 2)
    #expect(stub.getTransactionsCalls[0].order == .ASC)
  }
}

// MARK: - PNG helper

/// PNG files start with magic bytes 0x89 0x50 0x4E 0x47 ('\x89PNG').
private func expectPNG(_ data: Data, sourceLocation: SourceLocation = #_sourceLocation) {
  #expect(!data.isEmpty, sourceLocation: sourceLocation)
  #expect(data.count > 100, sourceLocation: sourceLocation)
  #expect(
    data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47,
    sourceLocation: sourceLocation
  )
}
