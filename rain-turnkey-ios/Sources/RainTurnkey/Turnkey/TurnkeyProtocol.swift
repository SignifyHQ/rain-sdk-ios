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
  /// On the signup path, `signupWalletAccounts` become the accounts of a single custom wallet
  /// created atomically with the sub-organization (one seed for every chain family); ignored on
  /// the login path. Distinctly named and fixed-arity so it cannot collide with the vendor's
  /// defaulted `completeOtp(...)`.
  func completeOtp(
    otpId: String,
    otpCode: String,
    otpEncryptionTargetBundle: String,
    contact: String,
    otpType: OtpType,
    sessionKey: String,
    signupWalletAccounts: [WalletAccountParams]
  ) async throws

  /// Derives additional accounts from an EXISTING wallet's seed (no new wallet, no new seed)
  /// and refreshes the wallet list.
  func addAccountsToTurnkeyWallet(
    walletId: String,
    accounts: [WalletAccountParams]
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
    sessionKey: String,
    signupWalletAccounts: [WalletAccountParams]
  ) async throws {
    // The custom wallet is created atomically inside the signup call, closing the window where
    // the sub-organization exists but wallet provisioning failed. Login ignores these params.
    // CreateSubOrgParams has no public initializer at swift-sdk 4.0.0 — its Decodable witness is
    // the only way to construct one from outside the vendor module.
    var subOrgParams = try JSONDecoder().decode(CreateSubOrgParams.self, from: Data("{}".utf8))
    subOrgParams.customWallet = v1WalletParams(
      accounts: signupWalletAccounts,
      mnemonicLength: 12,
      walletName: "Wallet"
    )
    _ = try await completeOtp(
      otpId: otpId,
      otpCode: otpCode,
      otpEncryptionTargetBundle: otpEncryptionTargetBundle,
      contact: contact,
      otpType: otpType,
      createSubOrgParams: subOrgParams,
      // Server-side: kills every other login session the user has, on every device — a second
      // phone logging in logs the first out (documented on the managed TurnkeyConfig init;
      // Android passes the same value).
      invalidateExisting: true,
      sessionKey: sessionKey
    )
  }

  internal func addAccountsToTurnkeyWallet(
    walletId: String,
    accounts: [WalletAccountParams]
  ) async throws {
    // The vendor exposes create_wallet_accounts only on the raw client; in production the
    // context's client is always the concrete TurnkeyClient.
    guard let client = turnkeyClient as? TurnkeyClient, let session else {
      throw TurnkeySwiftError.invalidSession
    }
    _ = try await client.createWalletAccounts(TCreateWalletAccountsBody(
      organizationId: session.organizationId,
      accounts: accounts,
      walletId: walletId
    ))
    try await refreshWallets()
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
