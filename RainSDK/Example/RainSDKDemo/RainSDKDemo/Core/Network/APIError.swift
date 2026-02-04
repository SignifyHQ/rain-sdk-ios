import Foundation

/// Errors that can occur when calling any API.
enum APIError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case emptyResponse
  case noCreditContracts
  case decodingError(Error)
  case serverError(statusCode: Int, data: Data?)
  case networkError(Error)

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid request URL."
    case .invalidResponse:
      return "Invalid response from server."
    case .emptyResponse:
      return "Server returned no data."
    case .noCreditContracts:
      return "No credit contracts found."
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    case .serverError(let statusCode, let data):
      let body = data.flatMap { String(data: $0, encoding: .utf8) }.map { b in
        b.count > 300 ? String(b.prefix(300)) + "…" : b
      }.map { " \($0)" } ?? ""
      return "Server error \(statusCode).\(body)"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    }
  }
}
