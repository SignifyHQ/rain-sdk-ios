import Foundation

/// Repository for POST /v1/rain/person/withdrawal/signature.
final class WithdrawalSignatureRepository {
  private let client: APIClient
  private let encoder: JSONEncoder

  init(client: APIClient? = nil, encoder: JSONEncoder = JSONEncoder()) {
    if let client = client {
      self.client = client
    } else {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      self.client = APIClient(decoder: decoder)
    }
    self.encoder = encoder
  }

  /// Requests withdrawal signature from the API.
  /// - Parameters:
  ///   - chainId: Chain ID.
  ///   - token: Token (e.g. contract address or symbol).
  ///   - amount: Amount string.
  ///   - recipientAddress: Recipient address.
  ///   - isAmountNative: Whether amount is in native token (default true).
  /// - Returns: Withdrawal signature entity (status, signature, expiresAt, etc.).
  func getWithdrawalSignature(
    chainId: Int,
    token: String,
    amount: String,
    recipientAddress: String,
    isAmountNative: Bool = true
  ) async throws -> RainWithdrawalSignatureEntity {
    let request = WithdrawalSignatureRequest(
      chainId: chainId,
      token: token,
      amount: amount,
      recipientAddress: recipientAddress,
      isAmountNative: isAmountNative
    )
    let endpoint = Endpoint.withdrawalSignature(request: request)
    let response: RainWithdrawalSignatureResponse = try await client.request(endpoint, as: RainWithdrawalSignatureResponse.self)
    return response
  }
}
