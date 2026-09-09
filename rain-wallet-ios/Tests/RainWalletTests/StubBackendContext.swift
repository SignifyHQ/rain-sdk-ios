import Combine
import Foundation
import TurnkeySwift
@testable import RainTurnkey

/// Minimal inert `TurnkeyContextProtocol` so RainWallet tests can construct providers without
/// touching the vendor singleton (which traps unconfigured in a test host). Test targets cannot
/// import each other, so this is deliberately not RainTurnkeyTests' richer `MockTurnkey`.
final class StubBackendContext: TurnkeyContextProtocol, @unchecked Sendable {
  var wallets: [Wallet] = []
  var turnkeyClient: (any TurnkeyClientProtocol)?
  var session: Session?
  var authState: AuthState = .unAuthenticated

  var authStatePublisher: AnyPublisher<AuthState, Never> {
    Just(authState).eraseToAnyPublisher()
  }

  var sessionPublisher: AnyPublisher<Session?, Never> {
    Just(session).eraseToAnyPublisher()
  }

  func refreshWallets() async throws {}
  func refreshTurnkeySession(expirationSeconds: String?) async throws {}

  func signRawPayload(
    signWith: String,
    payload: String,
    encoding: PayloadEncoding,
    hashFunction: HashFunction
  ) async throws -> SignRawPayloadResult {
    throw RainSDKError.walletUnavailable
  }

  func sendOtp(contact: String, otpType: OtpType) async throws -> OtpChallenge {
    OtpChallenge(otpId: "otp-id", encryptionTargetBundle: "bundle")
  }

  var selectedStoredSessionKey: String?

  func completeOtp(
    otpId: String,
    otpCode: String,
    otpEncryptionTargetBundle: String,
    contact: String,
    otpType: OtpType,
    sessionKey: String,
    signupWalletAccounts: [WalletAccountParams]
  ) async throws {}

  func selectStoredSession(sessionKey: String) async throws {}

  func clearStoredSession(sessionKey: String?) {}

  func createTurnkeyWallet(
    walletName: String,
    accounts: [WalletAccountParams],
    mnemonicLength: Int
  ) async throws {}

  func addAccountsToTurnkeyWallet(
    walletId: String,
    accounts: [WalletAccountParams]
  ) async throws {}

  var exportMnemonicCalls: [String] = []
  var stubbedMnemonic = "stub mnemonic"

  struct ExportKeyCall: Equatable { let address: String; let encoding: ExportedKeyEncoding }
  var exportKeyCalls: [ExportKeyCall] = []
  var stubbedExportedKey = "stub-key"

  func exportWalletMnemonic(walletId: String) async throws -> String {
    exportMnemonicCalls.append(walletId)
    return stubbedMnemonic
  }

  func exportAccountPrivateKey(
    address: String,
    encoding: ExportedKeyEncoding
  ) async throws -> String {
    exportKeyCalls.append(ExportKeyCall(address: address, encoding: encoding))
    return stubbedExportedKey
  }
}
