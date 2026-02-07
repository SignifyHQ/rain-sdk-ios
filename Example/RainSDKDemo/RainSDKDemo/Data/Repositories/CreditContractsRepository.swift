import Foundation

/// Repository for person credit-contracts API. Uses `APIClient` and `Endpoint`.
final class CreditContractsRepository {
  private let client: APIClient

  /// Uses a client that decodes snake_case JSON keys (e.g. `contract_id`) to camelCase.
  init(client: APIClient? = nil) {
    if let client = client {
      self.client = client
    } else {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      self.client = APIClient(decoder: decoder)
    }
  }

  /// Fetches credit contracts from GET person/credit-contracts. API returns an array; returns first contract.
  func getCreditContracts() async throws -> RainCollateralContractResponse {
    try await client.request(.creditContracts, as: RainCollateralContractResponse.self)
  }
}
