import Foundation

/// API configuration: base URL and endpoint definitions (Moya-style enum).
enum APIConfig {
  /// Base URL for the service platform (dev). Change for staging/production.
  static let baseURL = URL(string: "https://service-platform.dev.liquidity-financial.com")!
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

/// API endpoints (Moya-style). Add a new case per API; implement path, method, task, headers, bodyData.
enum Endpoint {
  case creditContracts
  case withdrawalSignature(request: WithdrawalSignatureRequest)
  case restoreWallet(backupMethod: String)

  var path: String {
    switch self {
    case .creditContracts:
      return "v1/rain/person/credit-contracts"
    case .withdrawalSignature:
      return "v1/rain/person/withdrawal/signature"
    case .restoreWallet:
      return "v1/portal/backup"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .creditContracts:
      return .get
    case .withdrawalSignature:
      return .post
    case .restoreWallet:
      return .get
    }
  }

  var task: EndpointTask {
    switch self {
    case .creditContracts:
      return .requestPlain
    case .withdrawalSignature:
      return .requestPlain
    case .restoreWallet(let backupMethod):
      return .requestQuery(["backupMethod": backupMethod])
    }
  }

  /// Request body for endpoints that send an encodable object. Client encodes with the given encoder.
  /// Withdrawal signature API expects body { "request": { ... } }.
  func bodyData(encoder: JSONEncoder) throws -> Data? {
    switch self {
    case .creditContracts:
      return nil
    case .withdrawalSignature(let request):
      let body = WithdrawalSignatureRequestBody(request: request)
      return try encoder.encode(body)
    case .restoreWallet:
      return nil
    }
  }

  var headers: [String: String]? {
    switch self {
    case .creditContracts, .withdrawalSignature, .restoreWallet:
      return nil
    }
  }
}
