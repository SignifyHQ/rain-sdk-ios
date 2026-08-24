import Foundation
@testable import RainCore

/// URLProtocol double for the Rain REST API. Dispatches stubbed responses by URL path
/// suffix and records every request so tests can assert method / headers / query.
///
/// Unlike `MockURLProtocol` (JSON-RPC, installed globally), this one is scoped to a
/// dedicated `URLSession` via `protocolClasses`, so it never intercepts other suites'
/// traffic. The stub/record state is still static, so suites using it are `.serialized`
/// and each test runs inside `withStubs`.
final class MockRainApiURLProtocol: URLProtocol {
  struct StubResponse {
    let statusCode: Int
    let body: Data
    let error: Error?

    init(statusCode: Int = 200, json: String) {
      self.statusCode = statusCode
      self.body = Data(json.utf8)
      self.error = nil
    }

    init(error: Error) {
      self.statusCode = 0
      self.body = Data()
      self.error = error
    }
  }

  /// Per-path-suffix response queues; the last entry repeats once the queue drains.
  nonisolated(unsafe) private static var stubs: [(suffix: String, responses: [StubResponse])] = []
  nonisolated(unsafe) private(set) static var recorded: [URLRequest] = []
  private static let serialGate = AsyncGate()

  /// A URLSession whose requests are all served by this protocol.
  static func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockRainApiURLProtocol.self]
    return URLSession(configuration: config)
  }

  private static func acquire() async { await serialGate.acquire() }

  private static func release() {
    stubs.removeAll()
    recorded.removeAll()
    serialGate.release()
  }

  /// Serializes stub state across concurrently-running tests and guarantees cleanup.
  static func withStubs<T>(_ body: () async throws -> T) async rethrows -> T {
    await acquire()
    defer { release() }
    return try await body()
  }

  static func stub(_ suffix: String, _ responses: StubResponse...) {
    stubs.removeAll { $0.suffix == suffix }
    stubs.append((suffix: suffix, responses: responses))
  }

  static func recordedRequests(pathSuffix: String) -> [URLRequest] {
    recorded.filter { $0.url?.path.hasSuffix(pathSuffix) == true }
  }

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func stopLoading() {}

  override func startLoading() {
    MockRainApiURLProtocol.recorded.append(request)

    guard let path = request.url?.path,
          let index = MockRainApiURLProtocol.stubs.firstIndex(where: { path.hasSuffix($0.suffix) })
    else {
      let response = HTTPURLResponse(
        url: request.url!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil
      )!
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: Data())
      client?.urlProtocolDidFinishLoading(self)
      return
    }

    var entry = MockRainApiURLProtocol.stubs[index]
    let stub = entry.responses.first ?? StubResponse(statusCode: 404, json: "")
    if entry.responses.count > 1 {
      entry.responses.removeFirst()
      MockRainApiURLProtocol.stubs[index] = entry
    }

    if let error = stub.error {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }

    let response = HTTPURLResponse(
      url: request.url!,
      statusCode: stub.statusCode,
      httpVersion: "HTTP/1.1",
      headerFields: ["Content-Type": "application/json"]
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: stub.body)
    client?.urlProtocolDidFinishLoading(self)
  }
}
