import Foundation

// MARK: - Request

/// Request params for POST /v1/rain/person/withdrawal/signature.
/// API expects camelCase keys: chainId, token, amount, recipientAddress, isAmountNative.
struct WithdrawalSignatureRequest: Encodable {
  let chainId: Int
  let token: String
  let amount: String
  let recipientAddress: String
  let isAmountNative: Bool
}

/// Wrapper for the API body: server expects { "request": RainUserWithdrawalSignatureRequest }.
struct WithdrawalSignatureRequestBody: Encodable {
  let request: WithdrawalSignatureRequest
}

// MARK: - Entity protocols

/// Entity for the inner signature (data + salt).
public protocol RainSignatureEntity {
  var data: String? { get }
  var salt: String? { get }
}

/// Entity for the withdrawal signature API response.
public protocol RainWithdrawalSignatureEntity {
  var status: String? { get }
  var retryAfterSeconds: Int? { get }
  var signatureEntity: RainSignatureEntity? { get }
  var expiresAt: String? { get }
}

// MARK: - Response (Decodable)
// All properties optional (exclude id if any) so decoding succeeds when API omits keys.

/// Decodable response for the inner signature; conforms to RainSignatureEntity.
struct RainSignatureResponse: Decodable, RainSignatureEntity {
  let data: String?
  let salt: String?
}

/// Decodable response for POST /v1/rain/person/withdrawal/signature; conforms to RainWithdrawalSignatureEntity.
struct RainWithdrawalSignatureResponse: Decodable, RainWithdrawalSignatureEntity {
  let status: String?
  let retryAfterSeconds: Int?
  let signature: RainSignatureResponse?
  let expiresAt: String?

  var signatureEntity: RainSignatureEntity? { signature }
}
