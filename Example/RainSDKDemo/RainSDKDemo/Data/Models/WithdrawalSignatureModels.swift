import Foundation

// MARK: - Request

/// Request params for `GET /v1/issuing/users/{userId}/signatures/withdrawals`.
///
/// Differs from the old LF withdrawal/signature POST: it is a GET with query params and now
/// requires `adminAddress` (an admin of the collateral contract — see
/// `RainCollateralContractEntity.adminAddresses`). The Rain API expects camelCase query keys.
struct WithdrawalSignatureRequest: Encodable {
  let chainId: Int
  let token: String
  let amount: String
  let adminAddress: String
  let recipientAddress: String
  let isAmountNative: Bool

  /// Query items for the GET request (all values stringified).
  var queryItems: [String: String] {
    [
      "chainId": String(chainId),
      "token": token,
      "amount": amount,
      "adminAddress": adminAddress,
      "recipientAddress": recipientAddress,
      "isAmountNative": String(isAmountNative)
    ]
  }
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
  var retryAfter: Int? { get }
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

/// Decodable response for `GET .../signatures/withdrawals`; conforms to RainWithdrawalSignatureEntity.
///
/// Rain returns a status envelope: a non-"ready" status (or a missing signature) means the
/// signature is not yet available, optionally with a `retryAfter` hint.
struct RainWithdrawalSignatureResponse: Decodable, RainWithdrawalSignatureEntity {
  let status: String?
  let retryAfter: Int?
  let signature: RainSignatureResponse?
  let expiresAt: String?

  var signatureEntity: RainSignatureEntity? { signature }
}
