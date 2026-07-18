import Foundation

/// HTTP client for the Rain issuing REST API.
///
/// Auth model:
///  1. `POST /v1/issuing/users/{userId}/sessions` with an `Api-Key` header exchanges the
///     program key for a short-lived client session token (CST).
///  2. Data endpoints (contracts, withdrawal signatures) are called with
///     `Authorization: Bearer cst_…`.
///
/// Stateless: base URL and auth material are passed per call; caching lives in
/// `RainSessionManager` and orchestration in `RainApiService`. Follows the `JsonRpcClient`
/// conventions — plain `URLSession` async/await, typed `RainSDKError`s.
internal final class RainApiClient: Sendable {
  private let session: URLSession
  private let decoder = JSONDecoder()

  private static let maxErrorBodyChars = 300

  internal init(session: URLSession = .shared) {
    self.session = session
  }

  // MARK: - Wire DTOs

  private struct SessionResponse: Decodable {
    let token: String
    let expiresAt: String?
  }

  private struct ContractDto: Decodable {
    let id: String?
    let chainId: Int?
    let controllerAddress: String?
    let proxyAddress: String?
    let depositAddress: String?
    let adminAddresses: [String]?
    let contractVersion: Int?
    let tokens: [ContractTokenDto]?
  }

  private struct ContractTokenDto: Decodable {
    let address: String?
    let balance: String?
    let exchangeRate: Double?
    let advanceRate: Double?
  }

  private struct WithdrawalSignatureResponse: Decodable {
    struct Signature: Decodable {
      let data: String?
      let salt: String?
    }

    let status: String?
    let retryAfter: Int?
    let signature: Signature?
    let expiresAt: String?
  }

  // MARK: - Endpoints

  /// Mints a client session token.
  ///
  /// The request body must be empty AND carry no `Content-Type` header — Rain rejects an
  /// empty body that declares a content type with a 400 ("Body cannot be empty when
  /// content-type is set …").
  func createSession(baseURL: URL, credentials: RainApiCredentials) async throws -> RainSession {
    var request = URLRequest(
      url: url(baseURL, path: "v1/issuing/users/\(credentials.userId)/sessions", queryItems: nil)
    )
    request.httpMethod = "POST"
    request.setValue(credentials.apiKey, forHTTPHeaderField: "Api-Key")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let data = try await executeChecked(request, operation: "create session")
    let response: SessionResponse
    do {
      response = try decoder.decode(SessionResponse.self, from: data)
    } catch {
      throw RainSDKError.networkError(underlying: error)
    }
    guard !response.token.isEmpty else {
      throw RainSDKError.networkError(
        underlying: NSError(
          domain: "rain.api", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Create session returned no token"]
        )
      )
    }
    return RainSession(
      token: response.token,
      expiresAt: response.expiresAt.flatMap(RainSdk.parseISO8601)
    )
  }

  /// `GET /v1/issuing/users/{userId}/contracts` (CST auth). Tokens are not yet enriched.
  func getContracts(baseURL: URL, cst: String, userId: String) async throws -> [RainCollateralContract] {
    var request = URLRequest(
      url: url(baseURL, path: "v1/issuing/users/\(userId)/contracts", queryItems: nil)
    )
    request.httpMethod = "GET"
    request.setValue("Bearer \(cst)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let data = try await executeChecked(request, operation: "fetch contracts")
    let dtos: [ContractDto]
    do {
      dtos = try decoder.decode([ContractDto].self, from: data)
    } catch {
      throw RainSDKError.networkError(underlying: error)
    }
    return dtos.map { dto in
      RainCollateralContract(
        id: dto.id?.isEmpty == false ? dto.id : nil,
        chainId: dto.chainId ?? 0,
        proxyAddress: dto.proxyAddress ?? "",
        controllerAddress: dto.controllerAddress ?? "",
        depositAddress: dto.depositAddress?.isEmpty == false ? dto.depositAddress : nil,
        adminAddresses: dto.adminAddresses ?? [],
        contractVersion: dto.contractVersion,
        tokens: (dto.tokens ?? []).map { token in
          RainCollateralToken(
            address: token.address ?? "",
            balance: token.balance ?? "",
            exchangeRate: token.exchangeRate ?? 0,
            advanceRate: token.advanceRate ?? 0
          )
        }
      )
    }
  }

  /// `GET /v1/issuing/users/{userId}/signatures/withdrawals` (CST auth).
  ///
  /// - Parameter amountBaseUnits: Withdrawal amount in the token's base units (decimal string).
  /// - Throws: `RainSDKError.signatureNotReady` when `status != "ready"` or the signature is missing.
  func getWithdrawalSignature(
    baseURL: URL,
    cst: String,
    userId: String,
    chainId: Int,
    tokenAddress: String,
    amountBaseUnits: String,
    adminAddress: String,
    recipientAddress: String,
    isAmountNative: Bool
  ) async throws -> RainAdminSignature {
    let queryItems = [
      URLQueryItem(name: "chainId", value: String(chainId)),
      URLQueryItem(name: "token", value: tokenAddress),
      URLQueryItem(name: "amount", value: amountBaseUnits),
      URLQueryItem(name: "adminAddress", value: adminAddress),
      URLQueryItem(name: "recipientAddress", value: recipientAddress),
      URLQueryItem(name: "isAmountNative", value: isAmountNative ? "true" : "false"),
    ]
    var request = URLRequest(
      url: url(baseURL, path: "v1/issuing/users/\(userId)/signatures/withdrawals", queryItems: queryItems)
    )
    request.httpMethod = "GET"
    request.setValue("Bearer \(cst)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let data = try await executeChecked(request, operation: "fetch withdrawal signature")
    let response: WithdrawalSignatureResponse
    do {
      response = try decoder.decode(WithdrawalSignatureResponse.self, from: data)
    } catch {
      throw RainSDKError.networkError(underlying: error)
    }

    let status = response.status ?? ""
    let signatureData = response.signature?.data
    // "ready" without usable signature bytes is still not-ready — returning an empty
    // signature would only surface later as a confusing on-chain revert.
    guard status.lowercased() == "ready",
          let signatureData, !signatureData.isEmpty
    else {
      let trimmed = status.trimmingCharacters(in: .whitespaces)
      throw RainSDKError.signatureNotReady(
        status: trimmed.isEmpty ? "unknown" : status,
        retryAfter: response.retryAfter
      )
    }
    return RainAdminSignature(
      salt: response.signature?.salt ?? "",
      signature: signatureData,
      expiresAt: response.expiresAt ?? ""
    )
  }

  // MARK: - Shared request/response handling

  private func url(_ baseURL: URL, path: String, queryItems: [URLQueryItem]?) -> URL {
    let full = baseURL.appendingPathComponent(path)
    guard var components = URLComponents(url: full, resolvingAgainstBaseURL: false) else { return full }
    if let queryItems, !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    return components.url ?? full
  }

  /// Executes `request`, returning the body on 2xx. 401/403 map to `.unauthorized`, other
  /// non-2xx to `.apiError`, transport failures to `.networkError`.
  private func executeChecked(_ request: URLRequest, operation: String) async throws -> Data {
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      RainLogger.error("Rain API transport failure for \(operation): \(error.localizedDescription)")
      throw RainSDKError.networkError(underlying: error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw RainSDKError.networkError(
        underlying: NSError(
          domain: "rain.api", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Non-HTTP response for \(operation)"]
        )
      )
    }

    let statusCode = httpResponse.statusCode
    if statusCode == 401 || statusCode == 403 {
      RainLogger.error("Rain API \(operation) rejected with \(statusCode)")
      throw RainSDKError.unauthorized
    }
    guard (200...299).contains(statusCode) else {
      RainLogger.error("Rain API \(operation) failed with \(statusCode)")
      throw RainSDKError.apiError(statusCode: statusCode, message: Self.snippet(of: data))
    }
    return data
  }

  private static func snippet(of data: Data) -> String? {
    guard let text = String(data: data, encoding: .utf8) else { return nil }
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    return String(trimmed.prefix(maxErrorBodyChars))
  }
}
