import Foundation
@testable import RainSDK
import TurnkeySwift
import TurnkeyTypes

final class MockTurnkeyClient: TurnkeyClientProtocol {
  var mockBalances: [v1AssetBalance] = []
  var mockSendTransactionStatusId = "send-status-id"
  var mockTransactionHash = "0x" + String(repeating: "d", count: 64)
  var mockActivities: [v1Activity] = []

  var walletAddressBalanceCalls: [TGetWalletAddressBalancesBody] = []
  var ethSendTransactionCalls: [TEthSendTransactionBody] = []
  var sendTransactionStatusCalls: [TGetSendTransactionStatusBody] = []
  var getActivitiesCalls: [TGetActivitiesBody] = []

  func getWalletAddressBalances(
    _ input: TGetWalletAddressBalancesBody
  ) async throws -> TGetWalletAddressBalancesResponse {
    walletAddressBalanceCalls.append(input)

    return MockTurnkey.decode(
      WalletAddressBalancesResponseFixture(balances: mockBalances),
      as: TGetWalletAddressBalancesResponse.self
    )
  }

  func ethSendTransaction(
    _ input: TEthSendTransactionBody
  ) async throws -> TEthSendTransactionResponse {
    ethSendTransactionCalls.append(input)

    return MockTurnkey.decode(
      EthSendTransactionResponseFixture(
        activity: MockTurnkey.makeActivity(
          id: UUID().uuidString,
          from: input.from,
          to: input.to,
          caip2: input.caip2,
          value: input.value,
          data: input.data,
          sendTransactionStatusId: mockSendTransactionStatusId
        ),
        sendTransactionStatusId: mockSendTransactionStatusId
      ),
      as: TEthSendTransactionResponse.self
    )
  }

  func getSendTransactionStatus(
    _ input: TGetSendTransactionStatusBody
  ) async throws -> TGetSendTransactionStatusResponse {
    sendTransactionStatusCalls.append(input)

    return MockTurnkey.decode(
      SendTransactionStatusResponseFixture(
        error: nil,
        eth: v1EthSendTransactionStatus(txHash: mockTransactionHash),
        solana: nil,
        txError: nil,
        txStatus: "TX_STATUS_BROADCASTED"
      ),
      as: TGetSendTransactionStatusResponse.self
    )
  }

  func getActivities(
    _ input: TGetActivitiesBody
  ) async throws -> TGetActivitiesResponse {
    getActivitiesCalls.append(input)

    return MockTurnkey.decode(
      ActivitiesResponseFixture(activities: mockActivities),
      as: TGetActivitiesResponse.self
    )
  }
}

final class MockTurnkey: TurnkeyContextProtocol {
  struct SignRawPayloadCall: Sendable {
    let signWith: String
    let payload: String
    let encoding: PayloadEncoding
    let hashFunction: HashFunction
  }

  static let defaultWalletAddress = "0x1234567890123456789012345678901234567890"

  var wallets: [Wallet] = []
  var session: Session?
  var turnkeyClient: (any TurnkeyClientProtocol)?
  var refreshWalletsCallCount = 0
  var signRawPayloadCalls: [SignRawPayloadCall] = []

  var mockSignature = SignRawPayloadResult(
    r: String(repeating: "1", count: 64),
    s: String(repeating: "2", count: 64),
    v: "28"
  )

  init(
    wallets: [Wallet] = [MockTurnkey.defaultWallet()],
    session: Session? = MockTurnkey.defaultSession(),
    client: (any TurnkeyClientProtocol)? = MockTurnkeyClient()
  ) {
    self.wallets = wallets
    self.session = session
    self.turnkeyClient = client
  }

  func refreshWallets() async throws {
    refreshWalletsCallCount += 1
  }

  func signRawPayload(
    signWith: String,
    payload: String,
    encoding: PayloadEncoding,
    hashFunction: HashFunction
  ) async throws -> SignRawPayloadResult {
    signRawPayloadCalls.append(
      SignRawPayloadCall(
        signWith: signWith,
        payload: payload,
        encoding: encoding,
        hashFunction: hashFunction
      )
    )

    return mockSignature
  }
}

extension MockTurnkey {
  static func defaultSession() -> Session {
    decode(
      SessionFixture(
        exp: Date().addingTimeInterval(3600).timeIntervalSince1970,
        publicKey: "pubkey",
        sessionType: .readWrite,
        userId: "user-id",
        organizationId: "org-id",
        token: "jwt"
      ),
      as: Session.self
    )
  }

  static func defaultWallet() -> Wallet {
    decode(
      WalletFixture(
        walletId: "wallet-id",
        walletName: "wallet",
        createdAt: "0",
        updatedAt: "0",
        exported: false,
        imported: false,
        accounts: [
          WalletAccount(
            address: defaultWalletAddress,
            addressFormat: .address_format_ethereum,
            createdAt: externaldatav1Timestamp(nanos: "0", seconds: "0"),
            curve: .curve_secp256k1,
            organizationId: "org-id",
            path: "m/44'/60'/0'/0/0",
            pathFormat: .path_format_bip32,
            publicKey: nil,
            updatedAt: externaldatav1Timestamp(nanos: "0", seconds: "0"),
            walletAccountId: "wallet-account-id",
            walletDetails: nil,
            walletId: "wallet-id"
          )
        ]
      ),
      as: Wallet.self
    )
  }

  static func makeActivity(
    id: String,
    from: String,
    to: String,
    caip2: String,
    value: String?,
    data: String?,
    sendTransactionStatusId: String
  ) -> v1Activity {
    v1Activity(
      canApprove: false,
      canReject: false,
      createdAt: externaldatav1Timestamp(nanos: "0", seconds: "1714521600"),
      fingerprint: "fingerprint",
      id: id,
      intent: v1Intent(
        ethSendTransactionIntent: v1EthSendTransactionIntent(
          caip2: caip2,
          data: data,
          from: from,
          gasLimit: "21000",
          gasStationNonce: nil,
          maxFeePerGas: "1000000000",
          maxPriorityFeePerGas: "1000000000",
          nonce: "1",
          sponsor: false,
          to: to,
          value: value
        )
      ),
      organizationId: "org-id",
      result: v1Result(
        ethSendTransactionResult: v1EthSendTransactionResult(
          sendTransactionStatusId: sendTransactionStatusId
        )
      ),
      status: .activity_status_completed,
      type: .activity_type_eth_send_transaction,
      updatedAt: externaldatav1Timestamp(nanos: "0", seconds: "1714521600"),
      votes: []
    )
  }

  static func decode<T: Decodable, Source: Encodable>(
    _ source: Source,
    as type: T.Type = T.self
  ) -> T {
    let data = try! JSONEncoder().encode(source)
    return try! JSONDecoder().decode(type, from: data)
  }
}

private struct WalletAddressBalancesResponseFixture: Encodable {
  let balances: [v1AssetBalance]?
}

private struct EthSendTransactionResponseFixture: Encodable {
  let activity: v1Activity
  let sendTransactionStatusId: String
}

private struct SendTransactionStatusResponseFixture: Encodable {
  let error: v1TxError?
  let eth: v1EthSendTransactionStatus?
  let solana: v1SolanaSendTransactionStatus?
  let txError: String?
  let txStatus: String
}

private struct ActivitiesResponseFixture: Encodable {
  let activities: [v1Activity]
}

private struct SessionFixture: Encodable {
  let exp: TimeInterval
  let publicKey: String
  let sessionType: SessionType
  let userId: String
  let organizationId: String
  let token: String?

  enum CodingKeys: String, CodingKey {
    case exp
    case publicKey = "public_key"
    case sessionType = "session_type"
    case userId = "user_id"
    case organizationId = "organization_id"
    case token
  }
}

private struct WalletFixture: Encodable {
  let walletId: String
  let walletName: String
  let createdAt: String
  let updatedAt: String
  let exported: Bool
  let imported: Bool
  let accounts: [v1WalletAccount]
}
