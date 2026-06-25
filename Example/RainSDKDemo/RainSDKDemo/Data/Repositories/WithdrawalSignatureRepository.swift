import Foundation

/// Repository for `GET /v1/issuing/users/{userId}/signatures/withdrawals` (CST auth).
final class WithdrawalSignatureRepository {
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

  /// Requests an admin withdrawal signature from the Rain dev API.
  ///
  /// Differs from the old LF POST: it is a GET with query params and now requires
  /// `adminAddress` (an admin of the collateral contract). The response is a status envelope —
  /// a non-"ready" status (or a missing signature) is surfaced as `APIError.signatureNotReady`.
  /// - Parameters:
  ///   - chainId: Chain ID.
  ///   - token: Token contract address.
  ///   - amount: Amount in the token's smallest unit (base units), as a string.
  ///   - adminAddress: An admin of the collateral contract.
  ///   - recipientAddress: Recipient address.
  ///   - isAmountNative: Whether amount is in native token (default true).
  /// - Returns: Withdrawal signature entity (status, signature, expiresAt, etc.).
  func getWithdrawalSignature(
    chainId: Int,
    token: String,
    amount: String,
    adminAddress: String,
    recipientAddress: String,
    isAmountNative: Bool = true
  ) async throws -> RainWithdrawalSignatureEntity {
    guard let userId = RainAPICredentialsStorage.userId, !userId.isEmpty else {
      throw APIError.notConfigured
    }
    let cst = try await RainSessionManager.shared.validToken()
    let request = WithdrawalSignatureRequest(
      chainId: chainId,
      token: token,
      amount: amount,
      adminAddress: adminAddress,
      recipientAddress: recipientAddress,
      isAmountNative: isAmountNative
    )
    let response: RainWithdrawalSignatureResponse = try await client.request(
      .withdrawalSignature(userId: userId, request: request),
      as: RainWithdrawalSignatureResponse.self,
      extraHeaders: ["Authorization": "Bearer \(cst)"]
    )

    // A non-"ready" status (or a missing signature) means the signature isn't available yet.
    let isReady = response.status?.caseInsensitiveCompare("ready") == .orderedSame
    guard isReady, response.signatureEntity?.data != nil else {
      throw APIError.signatureNotReady(status: response.status, retryAfter: response.retryAfter)
    }
    return response
  }
}
