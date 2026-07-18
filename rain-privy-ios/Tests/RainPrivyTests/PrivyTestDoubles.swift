import Foundation
import PrivySDK
import RainCore
@testable import RainPrivy

// MARK: - PrivyWalletSource fakes

/// In-memory `PrivyWalletSource`: returns a configured wallet list (or nil = unauthenticated)
/// and counts lookups so tests can assert resolve-once behaviour.
final class FakeWalletSource: PrivyWalletSource, @unchecked Sendable {
  private let lock = NSLock()
  private var _lookups = 0
  private let wallets: [any PrivyEthereumSigner]?
  private let lookupDelayNs: UInt64

  init(wallets: [any PrivyEthereumSigner]?, lookupDelayNs: UInt64 = 0) {
    self.wallets = wallets
    self.lookupDelayNs = lookupDelayNs
  }

  var lookups: Int {
    lock.lock(); defer { lock.unlock() }
    return _lookups
  }

  private func recordLookup() {
    lock.lock(); defer { lock.unlock() }
    _lookups += 1
  }

  func embeddedEthereumWallets() async -> [any PrivyEthereumSigner]? {
    recordLookup()
    if lookupDelayNs > 0 {
      try? await Task.sleep(nanoseconds: lookupDelayNs)
    }
    return wallets
  }
}

/// Recording `PrivyEthereumSigner`: appends every `switchChain` / `request` to `events`
/// (thread-safe) and returns / throws a configured result. An optional artificial delay inside
/// `request` widens race windows for the send-serialization test.
final class FakeSigner: PrivyEthereumSigner, @unchecked Sendable {
  private let lock = NSLock()
  private var _events: [String] = []

  let address: String
  var requestResult: Result<String, Error>
  var requestDelayNs: UInt64 = 0

  init(address: String, requestResult: Result<String, Error> = .success("0xHASH")) {
    self.address = address
    self.requestResult = requestResult
  }

  var events: [String] {
    lock.lock(); defer { lock.unlock() }
    return _events
  }

  private func record(_ event: String) {
    lock.lock(); defer { lock.unlock() }
    _events.append(event)
  }

  func request(_ request: EthereumRpcRequest) async throws -> String {
    record("request:\(request.method)")
    if requestDelayNs > 0 {
      try? await Task.sleep(nanoseconds: requestDelayNs)
    }
    return try requestResult.get()
  }

  func switchChain(chainId: Int, rpcUrl: String?) async {
    record("switch:\(chainId)")
  }
}

// MARK: - Privy descriptor stub

/// Minimal `Privy` conformance for constructing a `PrivyConfig` in descriptor tests. Every member
/// traps — `PrivyProvider.id` / `.capabilities` never touch the vendor singleton.
final class UnimplementedPrivy: Privy, @unchecked Sendable {
  func awaitReady() async { fatalError("unimplemented") }
  func getAuthState() async -> AuthState { fatalError("unimplemented") }
  var user: (any PrivyUser)? { fatalError("unimplemented") }
  func getUser() async -> (any PrivyUser)? { fatalError("unimplemented") }
  var authState: AuthState { fatalError("unimplemented") }
  var authStateStream: AsyncStream<AuthState> { fatalError("unimplemented") }
  var email: any LoginWithEmail { fatalError("unimplemented") }
  var sms: any LoginWithSms { fatalError("unimplemented") }
  var siwe: any LoginWithSiwe { fatalError("unimplemented") }
  var siws: any LoginWithSiws { fatalError("unimplemented") }
  var customJwt: any LoginWithCustomAccessToken { fatalError("unimplemented") }
  var oAuth: any LoginWithOAuth { fatalError("unimplemented") }
  var passkey: any LoginWithPasskey { fatalError("unimplemented") }
  var mfa: any PrivyMfa { fatalError("unimplemented") }
  func onNetworkRestored() async { fatalError("unimplemented") }
}

// MARK: - TokenMetadataStore access

/// `TokenMetadataStore`'s initializer is internal to RainCore, so tests obtain the real store the
/// same way adapters do: register a capturing provider on a throwaway `RainSdk` and grab the
/// store from the `ProviderContext` handed to `create(context:)`.
enum TestTokenStore {
  private final class Box: @unchecked Sendable {
    var store: TokenMetadataStore?
  }

  private struct CapturingProvider: RainProvider {
    let box: Box
    var id: ProviderId { ProviderId("test-capture") }
    var capabilities: Set<Capability> { [] }
    func create(context: ProviderContext) async throws -> any RainWalletProvider {
      box.store = context.tokenStore
      return NullWalletProvider()
    }
  }

  private struct NullWalletProvider: RainWalletProvider {
    func address() async throws -> String { throw RainSDKError.walletUnavailable }
    func sendTransaction(chainId: Int, params: WalletTransactionParams) async throws -> String {
      throw RainSDKError.walletUnavailable
    }
    func getBalance(chainId: Int, token: Token) async throws -> Balance {
      throw RainSDKError.walletUnavailable
    }
    func getBalances(chainId: Int) async throws -> [Balance] {
      throw RainSDKError.walletUnavailable
    }
    func getTransactions(
      chainId: Int, limit: Int?, offset: Int?, order: WalletTransactionOrder?
    ) async throws -> [WalletTransaction] {
      throw RainSDKError.walletUnavailable
    }
  }

  /// Builds a real `TokenMetadataStore` seeded with `tokens`.
  static func make(chainId: Int, rpcUrl: String, tokens: [TokenInfo]) async throws -> TokenMetadataStore {
    let box = Box()
    let sdk = try RainSdk.builder()
      .rpcEndpoints([chainId: rpcUrl])
      .register(CapturingProvider(box: box))
      .registerTokens(tokens)
      .build()
    _ = try await sdk.provider(ProviderId("test-capture"))
    guard let store = box.store else {
      throw RainSDKError.internalLogicError(details: "token store was not captured")
    }
    return store
  }
}

// MARK: - Stubbed JSON-RPC transport

/// URLProtocol stub for `PrivyRpcClient`'s URLSession. Routes by request host so concurrently
/// running suites don't clobber each other's handlers.
final class StubURLProtocol: URLProtocol {
  /// host → handler(parsed JSON-RPC body) → HTTP body data
  nonisolated(unsafe) private static var handlers: [String: @Sendable ([String: Any]) -> Data] = [:]
  private static let lock = NSLock()

  static func setHandler(host: String, _ handler: @escaping @Sendable ([String: Any]) -> Data) {
    lock.lock(); defer { lock.unlock() }
    handlers[host] = handler
  }

  private static func handler(host: String) -> (@Sendable ([String: Any]) -> Data)? {
    lock.lock(); defer { lock.unlock() }
    return handlers[host]
  }

  /// A URLSession whose every request is served by the registered handlers.
  static func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: config)
  }

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let host = request.url?.host, let handler = Self.handler(host: host) else {
      client?.urlProtocol(self, didFailWithError: URLError(.cannotConnectToHost))
      return
    }

    let body = Self.bodyData(of: request)
    let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any] ?? [:]
    let responseData = handler(json)

    let response = HTTPURLResponse(
      url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1",
      headerFields: ["Content-Type": "application/json"]
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: responseData)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}

  /// URLSession delivers POST bodies via `httpBodyStream`, not `httpBody` — drain it.
  private static func bodyData(of request: URLRequest) -> Data {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return Data() }
    stream.open()
    defer { stream.close() }
    var data = Data()
    let bufferSize = 4096
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }
    while stream.hasBytesAvailable {
      let read = stream.read(buffer, maxLength: bufferSize)
      guard read > 0 else { break }
      data.append(buffer, count: read)
    }
    return data
  }
}

// MARK: - JSON-RPC response helpers

enum RpcStub {
  static func result(_ value: String) -> Data {
    try! JSONSerialization.data(withJSONObject: ["jsonrpc": "2.0", "id": 1, "result": value])
  }

  static func error(code: Int, message: String) -> Data {
    try! JSONSerialization.data(
      withJSONObject: ["jsonrpc": "2.0", "id": 1, "error": ["code": code, "message": message]]
    )
  }

  static func rawResult(_ value: Any) -> Data {
    try! JSONSerialization.data(withJSONObject: ["jsonrpc": "2.0", "id": 1, "result": value])
  }

  /// Pulls the `to` address out of an `eth_call` params list (first param is the call object).
  static func callTarget(_ body: [String: Any]) -> String? {
    let params = body["params"] as? [Any]
    return (params?.first as? [String: Any])?["to"] as? String
  }
}
