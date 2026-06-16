import Foundation

/// API configuration: base URL and endpoint definitions (Moya-style enum).
enum APIConfig {
  /// Base URL for the Rain dev API. Change for staging/production.
  ///
  /// Replaces the old Liquidity Financial service-platform host. Auth is now the Rain
  /// Client Session Token (CST) flow — see `RainSessionManager`.
  static let baseURL = URL(string: "https://api-dev.rain.xyz")!
}

// MARK: - Endpoints (Moya-style)

/// HTTP method for API requests.
enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

/// Request task: parameters, body, or plain. Add cases as needed (e.g. upload).
enum EndpointTask {
  case requestPlain
  case requestQuery([String: String])
  case requestBody(Data)
  case requestQueryAndBody(query: [String: String], body: Data)
}

/// Rain dev API endpoints (Moya-style). Add a new case per API; implement path, method, task.
///
/// All issuing endpoints are scoped to a Rain `userId` and authenticated with a CST
/// (`Authorization: Bearer cst_…`) — except `createSession`, which mints the CST using the
/// program `Api-Key` header instead. Auth headers are supplied by the caller (the session
/// manager / repositories) via `extraHeaders`, not baked into the endpoint.
enum Endpoint {
  /// `POST /v1/issuing/users/{userId}/sessions` — mints a CST. Sent with an `Api-Key` header
  /// and an empty body.
  case createSession(userId: String)
  /// `GET /v1/issuing/users/{userId}/contracts` — collateral contracts (array).
  case contracts(userId: String)
  /// `GET /v1/issuing/users/{userId}/signatures/withdrawals` — admin withdrawal signature.
  case withdrawalSignature(userId: String, request: WithdrawalSignatureRequest)

  var path: String {
    switch self {
    case .createSession(let userId):
      return "v1/issuing/users/\(userId)/sessions"
    case .contracts(let userId):
      return "v1/issuing/users/\(userId)/contracts"
    case .withdrawalSignature(let userId, _):
      return "v1/issuing/users/\(userId)/signatures/withdrawals"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .createSession:
      return .post
    case .contracts:
      return .get
    case .withdrawalSignature:
      return .get
    }
  }

  var task: EndpointTask {
    switch self {
    case .createSession:
      // Rain mints the CST from an empty POST body + Api-Key header.
      return .requestBody(Data())
    case .contracts:
      return .requestPlain
    case .withdrawalSignature(_, let request):
      return .requestQuery(request.queryItems)
    }
  }

  /// Request body for endpoints that send an encodable object. The Rain withdrawal-signature
  /// endpoint is now a GET with query params, so no endpoint carries an encodable body.
  func bodyData(encoder: JSONEncoder) throws -> Data? {
    return nil
  }

  var headers: [String: String]? {
    switch self {
    case .createSession, .contracts, .withdrawalSignature:
      return nil
    }
  }
}
