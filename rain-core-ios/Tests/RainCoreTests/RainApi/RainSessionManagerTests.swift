import Testing
import Foundation
@testable import RainCore

@Suite("RainSessionManager Tests")
struct RainSessionManagerTests {
  private let credentials = RainApiCredentials(apiKey: "key", userId: "user")

  /// Thread-safe mint counter + controllable clock for the actor under test.
  private final class Harness: @unchecked Sendable {
    private let lock = NSLock()
    private var mintCount = 0
    private var currentDate = Date(timeIntervalSince1970: 1_700_000_000)

    var mints: Int {
      lock.lock(); defer { lock.unlock() }
      return mintCount
    }

    func now() -> Date {
      lock.lock(); defer { lock.unlock() }
      return currentDate
    }

    func advance(by interval: TimeInterval) {
      lock.lock(); defer { lock.unlock() }
      currentDate = currentDate.addingTimeInterval(interval)
    }

    func makeManager(expiresIn: TimeInterval?) -> RainSessionManager {
      RainSessionManager(now: { self.now() }) { _ in
        let n: Int = {
          self.lock.lock(); defer { self.lock.unlock() }
          self.mintCount += 1
          return self.mintCount
        }()
        return RainSession(
          token: "cst_\(n)",
          expiresAt: expiresIn.map { self.now().addingTimeInterval($0) }
        )
      }
    }
  }

  @Test("reuses cached token while valid")
  func reusesCachedToken() async throws {
    let harness = Harness()
    let manager = harness.makeManager(expiresIn: 3600)

    let first = try await manager.validToken(for: credentials)
    let second = try await manager.validToken(for: credentials)

    #expect(first == "cst_1")
    #expect(second == "cst_1")
    #expect(harness.mints == 1)
  }

  @Test("re-mints inside the 60s expiry buffer")
  func remintsNearExpiry() async throws {
    let harness = Harness()
    let manager = harness.makeManager(expiresIn: 3600)

    _ = try await manager.validToken(for: credentials)
    harness.advance(by: 3600 - 30) // 30s left < 60s buffer

    let refreshed = try await manager.validToken(for: credentials)

    #expect(refreshed == "cst_2")
    #expect(harness.mints == 2)
  }

  @Test("re-mints when credentials change")
  func remintsOnCredentialChange() async throws {
    let harness = Harness()
    let manager = harness.makeManager(expiresIn: 3600)

    _ = try await manager.validToken(for: credentials)
    let other = try await manager.validToken(for: RainApiCredentials(apiKey: "key2", userId: "user"))

    #expect(other == "cst_2")
    #expect(harness.mints == 2)
  }

  @Test("missing expiry falls back to the five minute TTL")
  func fallbackTTL() async throws {
    let harness = Harness()
    let manager = harness.makeManager(expiresIn: nil)

    _ = try await manager.validToken(for: credentials)
    harness.advance(by: 120) // well inside fallback TTL minus buffer
    _ = try await manager.validToken(for: credentials)
    #expect(harness.mints == 1)

    harness.advance(by: 150) // 270s elapsed; 300 - 270 = 30s left < 60s buffer
    _ = try await manager.validToken(for: credentials)
    #expect(harness.mints == 2)
  }

  @Test("invalidate drops the cached token")
  func invalidateDropsToken() async throws {
    let harness = Harness()
    let manager = harness.makeManager(expiresIn: 3600)

    _ = try await manager.validToken(for: credentials)
    await manager.invalidate()
    _ = try await manager.validToken(for: credentials)

    #expect(harness.mints == 2)
  }

  @Test("concurrent callers share a single mint")
  func concurrentSingleMint() async throws {
    let harness = Harness()
    let manager = harness.makeManager(expiresIn: 3600)
    let creds = credentials

    let tokens = try await withThrowingTaskGroup(of: String.self) { group in
      for _ in 0..<20 {
        group.addTask { try await manager.validToken(for: creds) }
      }
      var results: [String] = []
      for try await token in group { results.append(token) }
      return results
    }

    #expect(Set(tokens) == ["cst_1"])
    #expect(harness.mints == 1)
  }
}
