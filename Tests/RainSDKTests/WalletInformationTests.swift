import Testing
import Foundation
import CoreGraphics
@testable import PortalSwift
@testable import RainSDK

@Suite("Wallet Information Tests")
struct WalletInformationTests {

  // MARK: - getWalletAddress

  @Test("getWalletAddress should throw walletUnavailable when called before initialization")
  func testGetWalletAddressBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getWalletAddress()
    }
  }

  @Test("getWalletAddress success returns address when provider has address")
  func testGetWalletAddressSuccess() async throws {
    let mockPortal = MockPortal()
    let expectedAddress = "0x1234567890123456789012345678901234567890"
    mockPortal.setMockAddress(expectedAddress, forNamespace: PortalNamespace.eip155)
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    let address = try await manager.getWalletAddress()
    #expect(address == expectedAddress)
  }

  // MARK: - generateWalletAddressQRCode

  @Test("generateWalletAddressQRCode should throw walletUnavailable when no provider")
  func testGenerateQRCodeNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.generateWalletAddressQRCode(dimension: 256)
    }
  }

  @Test("generateWalletAddressQRCode returns non-empty PNG data when provider has address")
  func testGenerateQRCodeSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let imageData = try await manager.generateWalletAddressQRCode(dimension: 256)
    #expect(!imageData.isEmpty)
    #expect(imageData.count > 100)
    // PNG files start with magic bytes 0x89 0x50 0x4E 0x47 ('\x89PNG'); assert valid PNG format.
    #expect(imageData[0] == 0x89 && imageData[1] == 0x50 && imageData[2] == 0x4E && imageData[3] == 0x47)
  }

  @Test("generateWalletAddressQRCode with custom dimension returns data")
  func testGenerateQRCodeCustomDimension() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0xabcdef1234567890", forNamespace: PortalNamespace.eip155)
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let imageData = try await manager.generateWalletAddressQRCode(dimension: 128)
    #expect(!imageData.isEmpty)
    // PNG files start with magic bytes 0x89 0x50 0x4E 0x47 ('\x89PNG'); assert valid PNG format.
    #expect(imageData[0] == 0x89 && imageData[1] == 0x50 && imageData[2] == 0x4E && imageData[3] == 0x47)
  }

  @Test("generateWalletAddressQRCode with custom colors returns data")
  func testGenerateQRCodeCustomColors() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let bg = CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    let fg = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    let imageData = try await manager.generateWalletAddressQRCode(
      dimension: 200,
      backgroundColor: bg,
      foregroundColor: fg
    )
    #expect(!imageData.isEmpty)
    // PNG files start with magic bytes 0x89 0x50 0x4E 0x47 ('\x89PNG'); assert valid PNG format.
    #expect(imageData[0] == 0x89 && imageData[1] == 0x50 && imageData[2] == 0x4E && imageData[3] == 0x47)
  }

  // MARK: - getTransactions

  @Test("getTransactions should throw walletUnavailable when no provider")
  func testGetTransactionsNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getTransactions(chainId: 1)
    }
  }

  @Test("getTransactions returns empty list when portal returns no transactions")
  func testGetTransactionsEmpty() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockFetchedTransactions = []
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let list = try await manager.getTransactions(chainId: 1)
    #expect(list.isEmpty)
  }

  @Test("getTransactions returns mapped WalletTransaction when portal returns FetchedTransaction")
  func testGetTransactionsReturnsMappedList() async throws {
    let mockPortal = MockPortal()
    let fetchedTx = Self.makeFetchedTransaction(
      hash: "0xabc123",
      from: "0xfrom",
      to: "0xto",
      blockNum: "100",
      chainId: 1
    )
    mockPortal.mockFetchedTransactions = [fetchedTx]
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let list = try await manager.getTransactions(chainId: 1)
    #expect(list.count == 1)
    #expect(list[0].hash == "0xabc123")
    #expect(list[0].from == "0xfrom")
    #expect(list[0].to == "0xto")
    #expect(list[0].blockNum == "100")
    #expect(list[0].chainId == 1)
  }

  @Test("getTransactions with order passes through and returns mapped list")
  func testGetTransactionsWithOrder() async throws {
    let mockPortal = MockPortal()
    let fetchedTx = Self.makeFetchedTransaction(hash: "0xdef", from: "0xa", to: "0xb", blockNum: "200", chainId: 137)
    mockPortal.mockFetchedTransactions = [fetchedTx]
    let configs = [NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let list = try await manager.getTransactions(chainId: 137, limit: 10, offset: 0, order: .DESC)
    #expect(list.count == 1)
    #expect(list[0].hash == "0xdef")
    #expect(list[0].chainId == 137)
  }

  @Test("getTransactions returns mapped WalletTransaction for Turnkey activities")
  func testGetTransactionsTurnkeySuccess() async throws {
    let client = MockTurnkeyClient()
    client.mockTransactionHash = "0x" + String(repeating: "b", count: 64)
    client.mockActivities = [
      MockTurnkey.makeActivity(
        id: "activity-1",
        from: "0xfrom",
        to: "0xto",
        caip2: "eip155:1",
        value: "1000000000000000000",
        data: "0x",
        sendTransactionStatusId: client.mockSendTransactionStatusId
      )
    ]

    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let manager = RainSDKManager(
      turnkey: MockTurnkey(client: client),
      transactionBuilder: MockTransactionBuilderService(networkConfigs: configs),
      networkConfigs: configs
    )

    let list = try await manager.getTransactions(chainId: 1, limit: 10, offset: 0, order: .DESC)

    #expect(list.count == 1)
    #expect(list[0].hash == client.mockTransactionHash)
    #expect(list[0].from == "0xfrom")
    #expect(list[0].to == "0xto")
    #expect(list[0].value == 1.0)
    #expect(list[0].chainId == 1)
    #expect(client.getActivitiesCalls.count == 1)
    #expect(client.sendTransactionStatusCalls.count == 1)
  }
}

private extension WalletInformationTests {
  /// Builds a minimal `FetchedTransaction` for tests (Portal type) via JSON decode.
  static func makeFetchedTransaction(
    hash: String,
    from: String,
    to: String,
    blockNum: String,
    chainId: Int
  ) -> FetchedTransaction {
    let json = """
    {
      "blockNum": "\(blockNum)",
      "uniqueId": "uid-\(hash)",
      "hash": "\(hash)",
      "from": "\(from)",
      "to": "\(to)",
      "value": 1.0,
      "category": "external",
      "metadata": { "blockTimestamp": "2024-01-01T00:00:00Z" },
      "chainId": \(chainId)
    }
    """
    return try! JSONDecoder().decode(FetchedTransaction.self, from: Data(json.utf8))
  }
}
