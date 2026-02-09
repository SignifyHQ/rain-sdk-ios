import Foundation

/// Generic API client for the demo. Use with `Endpoint` (Moya-style) or raw path/method.
/// Token is read from UserDefaults (AuthTokenStorage); set at token input view.
final class APIClient {
  private let baseURL: URL
  private let session: URLSession
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder

  /// Default headers for every request: Accept, and Authorization (Bearer) when token is in UserDefaults.
  private var defaultHeaders: [String: String] {
    var headers: [String: String] = ["Accept": "application/json"]
    if let token = AuthTokenStorage.getToken() {
      headers["Authorization"] = "Bearer \(token)"
    }
    return headers
  }

  /// - Parameters:
  ///   - baseURL: Base URL (e.g. from `APIConfig.baseURL`).
  ///   - session: URLSession to use (default `.shared`).
  ///   - decoder: JSONDecoder for decoding responses (default).
  ///   - encoder: JSONEncoder for encoding request bodies (default).
  init(
    baseURL: URL = APIConfig.baseURL,
    session: URLSession = .shared,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder()
  ) {
    self.baseURL = baseURL
    self.session = session
    self.decoder = decoder
    self.encoder = encoder
  }

  /// Builds the full URL for a path (e.g. `"person/credit-contracts"`).
  private func url(path: String, queryItems: [URLQueryItem]?) -> URL {
    let full = baseURL.appendingPathComponent(path)
    guard var components = URLComponents(url: full, resolvingAgainstBaseURL: false) else { return full }
    if let items = queryItems, !items.isEmpty {
      components.queryItems = items
    }
    return components.url ?? full
  }

  /// Performs a request and returns raw `Data`. Logs request and response for debugging.
  /// - Parameters:
  ///   - path: Path relative to base URL (e.g. `"person/credit-contracts"`).
  ///   - method: HTTP method.
  ///   - queryItems: Optional query parameters.
  ///   - body: Optional request body (e.g. for POST/PUT).
  ///   - extraHeaders: Optional extra headers (merged with default headers: Accept + Authorization from UserDefaults).
  func request(
    path: String,
    method: HTTPMethod = .get,
    queryItems: [URLQueryItem]? = nil,
    body: Data? = nil,
    extraHeaders: [String: String]? = nil
  ) async throws -> Data {
    let requestURL = url(path: path, queryItems: queryItems)
    var urlRequest = URLRequest(url: requestURL)
    urlRequest.httpMethod = method.rawValue
    defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
    extraHeaders?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
    urlRequest.httpBody = body
    if body != nil {
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    // Log request
    let bodyPreview = body.flatMap { String(data: $0, encoding: .utf8) }.map { " body: \($0.prefix(200))..." } ?? ""
    print("[API] \(method.rawValue) \(requestURL.absoluteString)\(bodyPreview)")

    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: urlRequest)
    } catch {
      print("[API] Network error: \(error.localizedDescription)")
      throw APIError.networkError(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      print("[API] Invalid response (not HTTPURLResponse)")
      throw APIError.invalidResponse
    }

    // Log response (pretty-printed JSON when possible)
    if (200...299).contains(httpResponse.statusCode) {
      print("[API] Response \(httpResponse.statusCode) \(requestURL.path) | body length: \(data.count)")
      print(prettyJSONString(from: data))
    } else {
      print("[API] Error \(httpResponse.statusCode) \(requestURL.path)")
      print(prettyJSONString(from: data))
      throw APIError.serverError(statusCode: httpResponse.statusCode, data: data)
    }

    return data
  }

  /// Returns pretty-printed JSON string for logging; falls back to raw string if not valid JSON.
  private func prettyJSONString(from data: Data) -> String {
    guard !data.isEmpty else { return "[API] Response body: <empty>" }
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
          let pretty = String(data: prettyData, encoding: .utf8) else {
      let raw = String(data: data, encoding: .utf8) ?? "<invalid UTF-8>"
      let preview = raw.count > 500 ? String(raw.prefix(500)) + "…" : raw
      return "[API] Response body: \(preview)"
    }
    let maxLength = 2000
    if pretty.count > maxLength {
      return "[API] Response body:\n\(String(pretty.prefix(maxLength)))…\n… (\(pretty.count - maxLength) more chars)"
    }
    return "[API] Response body:\n\(pretty)"
  }

  /// Performs a request and decodes the response as `T`.
  /// - Parameters:
  ///   - path: Path relative to base URL (e.g. `"person/credit-contracts"`).
  ///   - method: HTTP method.
  ///   - type: Decodable type to decode (e.g. `[MyModel].self`).
  ///   - queryItems: Optional query parameters.
  ///   - body: Optional request body.
  ///   - extraHeaders: Optional extra headers.
  func request<T: Decodable>(
    path: String,
    method: HTTPMethod = .get,
    as type: T.Type,
    queryItems: [URLQueryItem]? = nil,
    body: Data? = nil,
    extraHeaders: [String: String]? = nil
  ) async throws -> T {
    let data = try await request(
      path: path,
      method: method,
      queryItems: queryItems,
      body: body,
      extraHeaders: extraHeaders
    )
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      print("[API] Decoding error: \(error)")
      print(prettyJSONString(from: data))
      throw APIError.decodingError(error)
    }
  }

  // MARK: - Endpoint (Moya-style)

  /// Performs a request for the given endpoint and returns raw `Data`.
  /// For endpoints with an encodable body (e.g. withdrawalSignature), body is encoded via endpoint.bodyData(encoder:).
  func request(_ endpoint: Endpoint) async throws -> Data {
    let (queryItems, bodyFromTask) = queryItemsAndBody(for: endpoint.task)
    let body = try endpoint.bodyData(encoder: encoder) ?? bodyFromTask
    return try await request(
      path: endpoint.path,
      method: endpoint.method,
      queryItems: queryItems,
      body: body,
      extraHeaders: endpoint.headers
    )
  }

  /// Performs a request for the given endpoint and decodes the response as `T`.
  func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
    let data = try await request(endpoint)
    if data.isEmpty {
      print("[API] Decoding skipped: response body is empty")
      throw APIError.emptyResponse
    }
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      print("[API] Decoding error: \(error)")
      print(prettyJSONString(from: data))
      throw APIError.decodingError(error)
    }
  }

  private func queryItemsAndBody(for task: EndpointTask) -> (queryItems: [URLQueryItem]?, body: Data?) {
    switch task {
    case .requestPlain:
      return (nil, nil)
    case .requestQuery(let params):
      let items = params.map { URLQueryItem(name: $0.key, value: $0.value) }
      return (items, nil)
    case .requestBody(let data):
      return (nil, data)
    case .requestQueryAndBody(let params, let data):
      let items = params.map { URLQueryItem(name: $0.key, value: $0.value) }
      return (items, data)
    }
  }

  // MARK: - Raw path (convenience)

  /// GET request returning raw data.
  func get(path: String, queryItems: [URLQueryItem]? = nil, headers: [String: String]? = nil) async throws -> Data {
    try await request(path: path, method: .get, queryItems: queryItems, extraHeaders: headers)
  }

  /// GET request decoding response as `T`.
  func get<T: Decodable>(path: String, as type: T.Type, queryItems: [URLQueryItem]? = nil, headers: [String: String]? = nil) async throws -> T {
    try await request(path: path, method: .get, as: type, queryItems: queryItems, extraHeaders: headers)
  }

  /// POST request with optional JSON body, returning raw data.
  func post(path: String, body: Data? = nil, headers: [String: String]? = nil) async throws -> Data {
    try await request(path: path, method: .post, body: body, extraHeaders: headers)
  }

  /// POST request with optional JSON body, decoding response as `T`.
  func post<T: Decodable>(path: String, body: Data? = nil, as type: T.Type, headers: [String: String]? = nil) async throws -> T {
    try await request(path: path, method: .post, as: type, body: body, extraHeaders: headers)
  }
}
