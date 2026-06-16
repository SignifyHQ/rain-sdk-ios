import Foundation

/// Repository for the Rain collateral-contracts API. Uses `APIClient` + the CST session flow.
final class CreditContractsRepository {
  private let client: APIClient

  init(client: APIClient? = nil) {
    if let client = client {
      self.client = client
    } else {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      self.client = APIClient(decoder: decoder)
    }
  }

  /// Fetches collateral contracts from `GET /v1/issuing/users/{userId}/contracts` (CST auth).
  /// Rain returns an array of contracts; the demo uses the first.
  ///
  /// Token symbol/decimals are omitted by this endpoint — callers resolve them on-chain (see
  /// `RainSDKService.resolveTokenMetadata`).
  func getCreditContracts() async throws -> RainCollateralContractResponse {
    guard let userId = RainAPICredentialsStorage.userId, !userId.isEmpty else {
      throw APIError.notConfigured
    }
    let cst = try await RainSessionManager.shared.validToken()
    let contracts = try await client.request(
      .contracts(userId: userId),
      as: [RainContractDto].self,
      extraHeaders: ["Authorization": "Bearer \(cst)"]
    )
    guard let first = contracts.first else {
      throw APIError.noCreditContracts
    }
    return first.toCollateralContractResponse()
  }
}
