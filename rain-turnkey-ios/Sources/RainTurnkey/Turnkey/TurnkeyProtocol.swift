import Combine
import Foundation
import TurnkeyHttp
import TurnkeySwift
import TurnkeyTypes

internal protocol TurnkeyClientProtocol {
  func getWalletAddressBalances(
    _ input: TGetWalletAddressBalancesBody
  ) async throws -> TGetWalletAddressBalancesResponse

  func ethSendTransaction(
    _ input: TEthSendTransactionBody
  ) async throws -> TEthSendTransactionResponse

  func solSendTransaction(
    _ input: TSolSendTransactionBody
  ) async throws -> TSolSendTransactionResponse

  func getSendTransactionStatus(
    _ input: TGetSendTransactionStatusBody
  ) async throws -> TGetSendTransactionStatusResponse

  func getActivities(
    _ input: TGetActivitiesBody
  ) async throws -> TGetActivitiesResponse
}

extension TurnkeyClient: TurnkeyClientProtocol {}

/// An in-flight OTP: the id and TEE-signed encryption bundle from `sendOtp`, needed to complete
/// the flow. Module-owned so test doubles can construct it.
internal struct OtpChallenge: Sendable, Equatable {
  let otpId: String
  let encryptionTargetBundle: String
}

internal protocol TurnkeyContextProtocol: AnyObject {
  var wallets: [Wallet] { get }
  var session: Session? { get }
  var turnkeyClient: (any TurnkeyClientProtocol)? { get }
  var authState: AuthState { get }
  var authStatePublisher: AnyPublisher<AuthState, Never> { get }
  var sessionPublisher: AnyPublisher<Session?, Never> { get }

  func refreshWallets() async throws

  /// Refreshes the selected session; `nil` `expirationSeconds` uses Turnkey's default TTL.
  /// Distinctly named so it cannot collide with the vendor's defaulted `refreshSession(...)`.
  func refreshTurnkeySession(expirationSeconds: String?) async throws

  func signRawPayload(
    signWith: String,
    payload: String,
    encoding: PayloadEncoding,
    hashFunction: HashFunction
  ) async throws -> SignRawPayloadResult

  // MARK: Managed auth (email OTP via the auth proxy)

  /// Starts an OTP flow. Distinctly named so it cannot collide with the vendor's `initOtp`, and
  /// returns a module-owned value so mocks need not construct the vendor's result type.
  func sendOtp(contact: String, otpType: OtpType) async throws -> OtpChallenge

  /// The key the currently selected stored session lives under, if any.
  var selectedStoredSessionKey: String? { get }

  /// Completes the OTP flow (signup-or-login), storing the resulting session under `sessionKey`.
  /// Distinctly named and fixed-arity so it cannot collide with the vendor's defaulted
  /// `completeOtp(...)`.
  func completeOtp(
    otpId: String,
    otpCode: String,
    otpEncryptionTargetBundle: String,
    contact: String,
    otpType: OtpType,
    sessionKey: String
  ) async throws

  /// Activates the session stored under `sessionKey` (client, published session, auth state).
  func selectStoredSession(sessionKey: String) async throws

  /// Clears the session stored under `sessionKey`; `nil` clears the currently selected one
  /// (logout). Safe no-op when none exists.
  func clearStoredSession(sessionKey: String?)

  /// Creates a wallet with the given accounts on the authenticated account. Distinctly named so
  /// it cannot collide with the vendor's defaulted `createWallet(...)`.
  func createTurnkeyWallet(
    walletName: String,
    accounts: [WalletAccountParams],
    mnemonicLength: Int
  ) async throws
}

extension TurnkeyContext: TurnkeyContextProtocol {
  internal var turnkeyClient: (any TurnkeyClientProtocol)? {
    client
  }

  internal var authStatePublisher: AnyPublisher<AuthState, Never> {
    $authState.eraseToAnyPublisher()
  }

  internal var sessionPublisher: AnyPublisher<Session?, Never> {
    $session.eraseToAnyPublisher()
  }

  internal func refreshTurnkeySession(expirationSeconds: String?) async throws {
    if let expirationSeconds {
      try await refreshSession(expirationSeconds: expirationSeconds)
    } else {
      try await refreshSession()
    }
  }

  internal func sendOtp(contact: String, otpType: OtpType) async throws -> OtpChallenge {
    let result = try await initOtp(contact: contact, otpType: otpType)
    return OtpChallenge(otpId: result.otpId, encryptionTargetBundle: result.otpEncryptionTargetBundle)
  }

  internal var selectedStoredSessionKey: String? {
    selectedSessionKey
  }

  internal func completeOtp(
    otpId: String,
    otpCode: String,
    otpEncryptionTargetBundle: String,
    contact: String,
    otpType: OtpType,
    sessionKey: String
  ) async throws {
    _ = try await completeOtp(
      otpId: otpId,
      otpCode: otpCode,
      otpEncryptionTargetBundle: otpEncryptionTargetBundle,
      contact: contact,
      otpType: otpType,
      invalidateExisting: true,
      sessionKey: sessionKey
    )
  }

  internal func selectStoredSession(sessionKey: String) async throws {
    _ = try await setActiveSession(sessionKey: sessionKey)
  }

  internal func clearStoredSession(sessionKey: String?) {
    // The vendor resolves `nil` to the currently selected session.
    clearSession(for: sessionKey)
  }

  internal func createTurnkeyWallet(
    walletName: String,
    accounts: [WalletAccountParams],
    mnemonicLength: Int
  ) async throws {
    _ = try await createWallet(
      walletName: walletName,
      accounts: accounts,
      mnemonicLength: Int32(mnemonicLength)
    )
  }
}
