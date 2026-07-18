import Testing
import Foundation
@testable import RainCore

@Suite("RainApiClient Tests", .serialized)
struct RainApiClientTests {
  private let baseURL = URL(string: "https://rain-api.test")!
  private let credentials = RainApiCredentials(apiKey: "key-123", userId: "user-abc")

  private func makeClient() -> RainApiClient {
    RainApiClient(session: MockRainApiURLProtocol.makeSession())
  }

  // MARK: - Session

  @Test("createSession parses token and expiry")
  func sessionParses() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub(
        "/sessions",
        .init(json: #"{"token":"cst_abc","expiresAt":"2030-01-01T00:00:00Z","userId":"user-abc"}"#)
      )

      let session = try await makeClient().createSession(baseURL: baseURL, credentials: credentials)

      #expect(session.token == "cst_abc")
      #expect(session.expiresAt == RainSdk.parseISO8601("2030-01-01T00:00:00Z"))
    }
  }

  @Test("createSession sends Api-Key header with empty body and no Content-Type")
  func sessionRequestShape() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub(
        "/sessions",
        .init(json: #"{"token":"cst_abc","expiresAt":"2030-01-01T00:00:00Z"}"#)
      )

      _ = try await makeClient().createSession(baseURL: baseURL, credentials: credentials)

      let request = try #require(MockRainApiURLProtocol.recorded.first)
      #expect(request.httpMethod == "POST")
      #expect(request.url?.path == "/v1/issuing/users/user-abc/sessions")
      #expect(request.value(forHTTPHeaderField: "Api-Key") == "key-123")
      #expect(request.httpBody == nil && request.httpBodyStream == nil)
      // Rain 400s when an empty body declares a content type — must stay absent.
      #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }
  }

  @Test("createSession with unparseable expiry yields nil expiresAt")
  func sessionUnparseableExpiry() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: #"{"token":"cst_abc","expiresAt":"not-a-date"}"#))

      let session = try await makeClient().createSession(baseURL: baseURL, credentials: credentials)

      #expect(session.expiresAt == nil)
    }
  }

  // MARK: - Contracts

  @Test("getContracts parses full and minimal contracts and sends Bearer header")
  func contractsParse() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub(
        "/contracts",
        .init(json: #"""
        [
          {
            "id": "c-1",
            "chainId": 43114,
            "controllerAddress": "0xcontroller",
            "proxyAddress": "0xproxy",
            "depositAddress": "0xdeposit",
            "adminAddresses": ["0xadmin1", "0xadmin2"],
            "contractVersion": 2,
            "tokens": [
              {"address": "0xtoken", "balance": "12.5", "exchangeRate": 1.0, "advanceRate": 0.8}
            ]
          },
          {"chainId": 1, "controllerAddress": "0xc2", "proxyAddress": "0xp2"}
        ]
        """#)
      )

      let contracts = try await makeClient().getContracts(baseURL: baseURL, cst: "cst_abc", userId: "user-abc")

      let request = try #require(MockRainApiURLProtocol.recorded.first)
      #expect(request.url?.path == "/v1/issuing/users/user-abc/contracts")
      #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer cst_abc")

      #expect(contracts.count == 2)
      let full = contracts[0]
      #expect(full.id == "c-1")
      #expect(full.chainId == 43114)
      #expect(full.proxyAddress == "0xproxy")
      #expect(full.controllerAddress == "0xcontroller")
      #expect(full.depositAddress == "0xdeposit")
      #expect(full.adminAddresses == ["0xadmin1", "0xadmin2"])
      #expect(full.contractVersion == 2)
      #expect(full.tokens.count == 1)
      #expect(full.tokens[0].address == "0xtoken")
      #expect(full.tokens[0].balance == "12.5")
      #expect(full.tokens[0].balanceAmount == Decimal(string: "12.5"))
      #expect(full.tokens[0].symbol == nil)
      #expect(full.tokens[0].decimals == nil)

      let minimal = contracts[1]
      #expect(minimal.id == nil)
      #expect(minimal.depositAddress == nil)
      #expect(minimal.contractVersion == nil)
      #expect(minimal.adminAddresses.isEmpty)
      #expect(minimal.tokens.isEmpty)
    }
  }

  // MARK: - Withdrawal signature

  @Test("getWithdrawalSignature sends expected query params")
  func signatureQueryParams() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/signatures/withdrawals", Self.readySignature)

      _ = try await fetchSignature()

      let request = try #require(MockRainApiURLProtocol.recorded.first)
      let components = try #require(URLComponents(url: request.url!, resolvingAgainstBaseURL: false))
      #expect(components.path == "/v1/issuing/users/user-abc/signatures/withdrawals")
      let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })
      #expect(query["chainId"] == "43114")
      #expect(query["token"] == "0xtoken")
      #expect(query["amount"] == "1500000")
      #expect(query["adminAddress"] == "0xadmin")
      #expect(query["recipientAddress"] == "0xrecipient")
      #expect(query["isAmountNative"] == "true")
    }
  }

  @Test("getWithdrawalSignature maps ready response to RainAdminSignature")
  func signatureReady() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/signatures/withdrawals", Self.readySignature)

      let signature = try await fetchSignature()

      #expect(signature.salt == "0xsalt")
      #expect(signature.signature == "0xsigdata")
      #expect(signature.expiresAt == "2030-01-01T00:00:00Z")
    }
  }

  @Test("pending status throws signatureNotReady carrying retryAfter")
  func signaturePending() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/signatures/withdrawals", .init(json: #"{"status":"pending","retryAfter":30}"#))

      do {
        _ = try await fetchSignature()
        Issue.record("expected signatureNotReady")
      } catch RainSDKError.signatureNotReady(let status, let retryAfter) {
        #expect(status == "pending")
        #expect(retryAfter == 30)
      } catch {
        Issue.record("unexpected error: \(error)")
      }
    }
  }

  @Test("ready status without signature throws signatureNotReady")
  func signatureMissing() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/signatures/withdrawals", .init(json: #"{"status":"ready"}"#))

      do {
        _ = try await fetchSignature()
        Issue.record("expected signatureNotReady")
      } catch RainSDKError.signatureNotReady(_, let retryAfter) {
        #expect(retryAfter == nil)
      } catch {
        Issue.record("unexpected error: \(error)")
      }
    }
  }

  @Test("ready status with null signature data throws signatureNotReady")
  func signatureDataMissing() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub(
        "/signatures/withdrawals",
        .init(json: #"{"status":"ready","signature":{"data":null,"salt":"0xsalt"}}"#)
      )

      do {
        _ = try await fetchSignature()
        Issue.record("expected signatureNotReady")
      } catch RainSDKError.signatureNotReady {
        // expected
      } catch {
        Issue.record("unexpected error: \(error)")
      }
    }
  }

  // MARK: - Error mapping

  @Test("401 and 403 map to unauthorized", arguments: [401, 403])
  func unauthorizedMapping(statusCode: Int) async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/contracts", .init(statusCode: statusCode, json: "denied"))

      await #expect(throws: RainSDKError.unauthorized) {
        _ = try await makeClient().getContracts(baseURL: baseURL, cst: "cst_abc", userId: "user-abc")
      }
    }
  }

  @Test("500 maps to apiError carrying the status code")
  func serverErrorMapping() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/contracts", .init(statusCode: 500, json: "boom"))

      do {
        _ = try await makeClient().getContracts(baseURL: baseURL, cst: "cst_abc", userId: "user-abc")
        Issue.record("expected apiError")
      } catch RainSDKError.apiError(let statusCode, let message) {
        #expect(statusCode == 500)
        #expect(message == "boom")
      } catch {
        Issue.record("unexpected error: \(error)")
      }
    }
  }

  @Test("transport failure maps to networkError")
  func transportFailure() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub(
        "/contracts",
        .init(error: URLError(.notConnectedToInternet))
      )

      await #expect(throws: RainSDKError.networkError(underlying: URLError(.notConnectedToInternet))) {
        _ = try await makeClient().getContracts(baseURL: baseURL, cst: "cst_abc", userId: "user-abc")
      }
    }
  }

  @Test("non-JSON body maps to networkError")
  func nonJsonBody() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/contracts", .init(json: "<html>gateway error</html>"))

      do {
        _ = try await makeClient().getContracts(baseURL: baseURL, cst: "cst_abc", userId: "user-abc")
        Issue.record("expected networkError")
      } catch RainSDKError.networkError {
        // expected
      } catch {
        Issue.record("unexpected error: \(error)")
      }
    }
  }

  // MARK: - Helpers

  private static let readySignature = MockRainApiURLProtocol.StubResponse(
    json: #"{"status":"ready","signature":{"data":"0xsigdata","salt":"0xsalt"},"expiresAt":"2030-01-01T00:00:00Z"}"#
  )

  private func fetchSignature() async throws -> RainAdminSignature {
    try await makeClient().getWithdrawalSignature(
      baseURL: baseURL,
      cst: "cst_abc",
      userId: "user-abc",
      chainId: 43114,
      tokenAddress: "0xtoken",
      amountBaseUnits: "1500000",
      adminAddress: "0xadmin",
      recipientAddress: "0xrecipient",
      isAmountNative: true
    )
  }
}
