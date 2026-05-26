import Testing
import Foundation
@testable import RainSDK

/// Tests for the EVM chain-read layer.
/// Stubs `URLSession.shared` via `MockURLProtocol` — must run serialized.
@Suite("EVM ChainReader Tests", .serialized)
struct EVMChainReaderTests {

  private let walletAddress = "0x1234567890123456789012345678901234567890"
  private let usdcAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
  private let daiAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
  private let rpcUrl = "https://mainnet.infura.io/v3/test"
  /// Chain ID that's in `Multicall3.canonicallyDeployedChainIds` — picks the Multicall3 path.
  private let canonicalChainId = 1
  /// Chain ID not in `Multicall3.canonicallyDeployedChainIds` — picks the parallel path.
  private let nonCanonicalChainId = 11_155_111 // Sepolia (testnet; not in production allowlist)

  private func makeReader(chainId: Int = 1) -> EVMChainReader {
    let config = NetworkConfig.testConfig(chainId: chainId, rpcUrl: rpcUrl)
    return EVMChainReader(networkConfigResolver: { id in
      id == chainId ? config : nil
    })
  }

  // MARK: - Single-result methods

  @Test("getNativeBalance reads eth_getBalance and divides by 18 decimals")
  func testGetNativeBalance() async throws {
    try await MockURLProtocol.withInstalled {
      // 1 ETH = 10^18 wei = 0xde0b6b3a7640000
      MockURLProtocol.stub(method: "eth_getBalance", result: "0x0de0b6b3a7640000")

      let reader = makeReader()
      let balance = try await reader.getNativeBalance(chainId: 1, walletAddress: walletAddress)
      #expect(balance == 1.0)
      #expect(MockURLProtocol.recordedMethods == ["eth_getBalance"])
    }
  }

  @Test("getERC20Balance reads eth_call with custom decimals")
  func testGetERC20Balance() async throws {
    try await MockURLProtocol.withInstalled {
      // 100 USDC = 100 * 10^6 = 100_000_000 = 0x5f5e100
      MockURLProtocol.stub(method: "eth_call", result: "0x0000000000000000000000000000000000000000000000000000000005f5e100")

      let reader = makeReader()
      let balance = try await reader.getERC20Balance(
        chainId: 1,
        tokenAddress: usdcAddress,
        walletAddress: walletAddress,
        decimals: 6
      )
      #expect(balance == 100.0)
      #expect(MockURLProtocol.recordedMethods == ["eth_call"])
    }
  }

  @Test("getERC20Balance defaults to 18 decimals when none provided")
  func testGetERC20BalanceDefaultDecimals() async throws {
    try await MockURLProtocol.withInstalled {
      // 1.0 = 10^18 = 0xde0b6b3a7640000
      MockURLProtocol.stub(method: "eth_call", result: "0x0000000000000000000000000000000000000000000000000de0b6b3a7640000")

      let reader = makeReader()
      let balance = try await reader.getERC20Balance(
        chainId: 1,
        tokenAddress: daiAddress,
        walletAddress: walletAddress,
        decimals: nil
      )
      #expect(balance == 1.0)
    }
  }

  // MARK: - Address validation

  @Test("getNativeBalance throws when the wallet address is syntactically invalid")
  func testGetNativeBalanceRejectsMalformedAddress() async throws {
    let reader = makeReader()
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getNativeBalance(chainId: 1, walletAddress: "not-an-address")
    }
  }

  @Test("getERC20Balance throws when the token address is syntactically invalid")
  func testGetERC20BalanceRejectsMalformedToken() async throws {
    let reader = makeReader()
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getERC20Balance(
        chainId: 1,
        tokenAddress: "0xtoo-short",
        walletAddress: walletAddress,
        decimals: 6
      )
    }
  }

  // MARK: - Multicall3 batched balances

  @Test("getBalances on a canonically-deployed chain issues exactly one Multicall3 eth_call (no probe)")
  func testGetBalancesNativeOnly() async throws {
    try await MockURLProtocol.withInstalled {
      let response = encodedAggregate3Response(tuples: [
        (success: true, returnData: paddedUint256(value: "0de0b6b3a7640000"))  // 1 ETH
      ])
      MockURLProtocol.stub(method: "eth_call", result: response)

      let reader = makeReader(chainId: canonicalChainId)
      let balances = try await reader.getBalances(chainId: canonicalChainId, walletAddress: walletAddress, tokens: [])
      #expect(balances[""] == 1.0)
      #expect(balances.count == 1)
      // Static deployment list — no eth_getCode probe.
      #expect(MockURLProtocol.recordedMethods == ["eth_call"])
    }
  }

  @Test("getBalances batches native + tokens into a single Multicall3 call")
  func testGetBalancesBatchHappyPath() async throws {
    try await MockURLProtocol.withInstalled {
      let tokens = [
        TokenSpec(chainId: 1, address: usdcAddress, symbol: "USDC", decimals: 6),
        TokenSpec(chainId: 1, address: daiAddress, symbol: "DAI", decimals: 18)
      ]
      let response = encodedAggregate3Response(tuples: [
        (success: true, returnData: paddedUint256(value: "06f05b59d3b20000")),  // 0.5 * 10^18
        (success: true, returnData: paddedUint256(value: "0ee6b280")),          // 250 * 10^6
        (success: true, returnData: paddedUint256(value: "0de0b6b3a7640000"))   // 1 * 10^18
      ])
      MockURLProtocol.stub(method: "eth_call", result: response)

      let reader = makeReader(chainId: canonicalChainId)
      let balances = try await reader.getBalances(chainId: canonicalChainId, walletAddress: walletAddress, tokens: tokens)
      #expect(balances[""] == 0.5)
      #expect(balances[usdcAddress] == 250.0)
      #expect(balances[daiAddress] == 1.0)
      #expect(MockURLProtocol.recordedMethods == ["eth_call"])
    }
  }

  @Test("getBalances omits tokens whose Multicall3 entry reports success=false")
  func testGetBalancesPerEntryFailureOmitsToken() async throws {
    try await MockURLProtocol.withInstalled {
      let tokens = [
        TokenSpec(chainId: 1, address: usdcAddress, symbol: "USDC", decimals: 6),
        TokenSpec(chainId: 1, address: daiAddress, symbol: "DAI", decimals: 18)
      ]
      let response = encodedAggregate3Response(tuples: [
        (success: true, returnData: paddedUint256(value: "0de0b6b3a7640000")),
        (success: false, returnData: ""),
        (success: true, returnData: paddedUint256(value: "0de0b6b3a7640000"))
      ])
      MockURLProtocol.stub(method: "eth_call", result: response)

      let reader = makeReader(chainId: canonicalChainId)
      let balances = try await reader.getBalances(chainId: canonicalChainId, walletAddress: walletAddress, tokens: tokens)
      // Native + DAI present, USDC (the failed entry) omitted.
      #expect(balances[""] != nil)
      #expect(balances[daiAddress] != nil)
      #expect(balances[usdcAddress] == nil)
    }
  }

  @Test("getBalances throws invalidConfig when chain has no RPC URL configured")
  func testGetBalancesUnknownChain() async throws {
    let reader = makeReader(chainId: 1)
    await #expect(throws: RainSDKError.self) {
      _ = try await reader.getBalances(chainId: 99999, walletAddress: walletAddress, tokens: [])
    }
  }

  @Test("resolveRpcUrl reports the correct chainId when the configured URL is unparseable")
  func testInvalidRpcUrlReportsCorrectChain() async throws {
    let badConfig = NetworkConfig.testConfig(chainId: 1, rpcUrl: "")
    let reader = EVMChainReader(networkConfigResolver: { id in id == 1 ? badConfig : nil })
    do {
      _ = try await reader.getNativeBalance(chainId: 1, walletAddress: walletAddress)
      Issue.record("Expected invalidConfig to throw")
    } catch let error as RainSDKError {
      if case .invalidConfig(let chainId, _) = error {
        #expect(chainId == 1)
      } else {
        Issue.record("Expected .invalidConfig, got \(error)")
      }
    }
  }

  // MARK: - Parallel fallback path (non-canonical chain)

  @Test("getBalances on a non-canonical chain takes the parallel fallback path")
  func testGetBalancesFallback() async throws {
    try await MockURLProtocol.withInstalled {
      MockURLProtocol.stub(method: "eth_getBalance", result: "0x0de0b6b3a7640000") // 1 ETH
      MockURLProtocol.stub(method: "eth_call", result: "0x0000000000000000000000000000000000000000000000000000000005f5e100") // 100 (6dp)

      let tokens = [
        TokenSpec(chainId: nonCanonicalChainId, address: usdcAddress, symbol: "USDC", decimals: 6),
        TokenSpec(chainId: nonCanonicalChainId, address: daiAddress, symbol: "DAI", decimals: 6)
      ]
      let reader = makeReader(chainId: nonCanonicalChainId)
      let balances = try await reader.getBalances(chainId: nonCanonicalChainId, walletAddress: walletAddress, tokens: tokens)

      #expect(balances[""] == 1.0)
      #expect(balances[usdcAddress] == 100.0)
      #expect(balances[daiAddress] == 100.0)
      // No probe; 1 eth_getBalance + 2 eth_call (one per token).
      #expect(MockURLProtocol.recordedMethods.filter { $0 == "eth_getCode" }.count == 0)
      #expect(MockURLProtocol.recordedMethods.filter { $0 == "eth_getBalance" }.count == 1)
      #expect(MockURLProtocol.recordedMethods.filter { $0 == "eth_call" }.count == 2)
    }
  }

  // MARK: - Aggregate3 response fixture helpers

  /// Returns a uint256 hex with `0x` prefix, given the trailing significant nibbles.
  private func paddedUint256(value: String) -> String {
    let padded = String(repeating: "0", count: max(0, 64 - value.count)) + value
    return "0x" + padded
  }

  /// Builds a canonical ABI-encoded `aggregate3` response containing the supplied tuples.
  private func encodedAggregate3Response(tuples: [(success: Bool, returnData: String)]) -> String {
    // Outer offset = 0x20, then [length, offsets..., bodies...]
    var out = "0x"
    out += hex32(32)
    out += hex32(tuples.count)
    let headerSize = 32 * tuples.count
    // Compute each tuple's body size: 96 (head) + padded(returnData)
    var offsets: [Int] = []
    var bodies: [String] = []
    var running = headerSize
    for tuple in tuples {
      offsets.append(running)
      let dataHex = stripPrefix(tuple.returnData)
      let dataBytes = dataHex.count / 2
      let paddedBytes = ((dataBytes + 31) / 32) * 32
      let bodySize = 96 + paddedBytes
      running += bodySize
      // Body: success(32) + dataOffset(32 = 0x40) + dataLength(32) + paddedData
      var body = hex32(tuple.success ? 1 : 0)
      body += hex32(64)
      body += hex32(dataBytes)
      let padChars = paddedBytes * 2 - dataHex.count
      body += dataHex + String(repeating: "0", count: padChars)
      bodies.append(body)
    }
    for offset in offsets {
      out += hex32(offset)
    }
    for body in bodies {
      out += body
    }
    return out
  }

  private func hex32(_ value: Int) -> String {
    let h = String(value, radix: 16)
    return String(repeating: "0", count: max(0, 64 - h.count)) + h
  }

  private func stripPrefix(_ s: String) -> String {
    (s.hasPrefix("0x") || s.hasPrefix("0X")) ? String(s.dropFirst(2)) : s
  }
}
