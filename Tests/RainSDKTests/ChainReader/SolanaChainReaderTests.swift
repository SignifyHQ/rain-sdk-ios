import Testing
import Foundation
import Web3
@testable import RainSDK

@Suite("SolanaChainReader", .serialized)
struct SolanaChainReaderTests {
  private static let host = "solana.test"
  private static let rpcUrl = "https://solana.test/rpc"
  private let address = Base58.encode((0..<32).map { UInt8($0) })

  private func makeReader() -> SolanaChainReader {
    SolanaChainReader(networkConfigs: [.testConfig(chainId: SolanaChains.mainnet, rpcUrl: Self.rpcUrl)])
  }

  @Test("native balance reads lamports and converts to SOL")
  func nativeBalance() async throws {
    try await MockURLProtocol.withInstalled {
      MockURLProtocol.interceptedHosts = [Self.host]
      MockURLProtocol.stub(method: "getBalance", result: ["value": 1_500_000_000])
      let reader = makeReader()

      let sol = try await reader.getNativeBalance(chainId: SolanaChains.mainnet, walletAddress: address)
      #expect(sol == 1.5)

      let balance = try await reader.getBalance(
        chainId: SolanaChains.mainnet, walletAddress: address, token: .native, tokenInfo: nil)
      #expect(balance.token == .native)
      #expect(balance.symbol == "SOL")
      #expect(balance.decimals == 9)
      #expect(balance.rawAmount == BigUInt(1_500_000_000))
      #expect(balance.decimalAmount == Decimal(string: "1.5"))
    }
  }

  @Test("getBalances returns native only")
  func balancesNativeOnly() async throws {
    try await MockURLProtocol.withInstalled {
      MockURLProtocol.interceptedHosts = [Self.host]
      MockURLProtocol.stub(method: "getBalance", result: ["value": 1_000_000_000])
      let reader = makeReader()
      let balances = try await reader.getBalances(chainId: SolanaChains.mainnet, walletAddress: address, tokens: [])
      #expect(balances.count == 1)
      #expect(balances.first?.token == .native)
    }
  }

  @Test("SPL / ERC-20 / metadata reads are unsupported and throw")
  func unsupportedReadsThrow() async {
    let reader = makeReader()
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getBalance(
        chainId: SolanaChains.mainnet, walletAddress: address,
        token: .contract(address: "mint"), tokenInfo: nil)
    }
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getDecimals(chainId: SolanaChains.mainnet, tokenAddress: "mint")
    }
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getSymbol(chainId: SolanaChains.mainnet, tokenAddress: "mint")
    }
  }

  @Test("invalid Solana address throws")
  func invalidAddressThrows() async {
    let reader = makeReader()
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getNativeBalance(chainId: SolanaChains.mainnet, walletAddress: "not-base58-0OIl")
    }
  }
}
