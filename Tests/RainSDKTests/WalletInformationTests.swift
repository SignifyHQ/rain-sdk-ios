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
}
