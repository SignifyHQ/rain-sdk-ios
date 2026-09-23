import Testing
import AuthenticationServices
import Foundation
import TurnkeyHttp
import TurnkeySwift
@_spi(RainAdapter) @testable import RainCore
@_spi(RainWallet) @testable import RainTurnkey

@Suite("Turnkey Managed Auth")
struct TurnkeyManagedAuthTests {
  init() { TurnkeyErrorMapping.registerOnce() }

  private func makeController(
    turnkey: MockTurnkey,
    configurationError: RainError? = nil,
    rpId: String? = nil
  ) -> TurnkeyManagedAuthController {
    TurnkeyManagedAuthController(
      context: turnkey,
      configurationError: configurationError,
      rpId: rpId
    )
  }

  // MARK: - OTP flow

  @Test("sendLoginCode starts an email OTP for the given address")
  func testSendLoginCode() async throws {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .email("user@example.com"))

    #expect(turnkey.sendOtpCalls == [.init(contact: "user@example.com", otpType: .email)])
  }

  @Test("confirmLoginCode without a prior sendLoginCode throws invalidConfig")
  func testConfirmWithoutSend() async {
    let controller = makeController(turnkey: MockTurnkey(session: nil))

    await #expect(throws: RainError.self) {
      try await controller.confirmLoginCode("123456")
    }
  }

  @Test("confirmLoginCode completes the OTP with the stashed challenge under a per-attempt key")
  func testConfirmLoginCodeHappyPath() async throws {
    let turnkey = MockTurnkey(
      wallets: [MockTurnkey.dualCurveWallet()],
      session: nil
    )
    turnkey.stubbedOtpChallenge = OtpChallenge(otpId: "otp-1", encryptionTargetBundle: "bundle-1")
    turnkey.onCompleteOtp = {
      turnkey.session = MockTurnkey.defaultSession()
      turnkey.authState = .authenticated
    }
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .email("user@example.com"))
    try await controller.confirmLoginCode("123456")

    // No session to supersede — nothing is ever cleared.
    #expect(turnkey.clearStoredSessionCalls.isEmpty)
    let call = try #require(turnkey.completeOtpCalls.first)
    #expect(turnkey.completeOtpCalls.count == 1)
    #expect(call.otpId == "otp-1")
    #expect(call.otpCode == "123456")
    #expect(call.otpEncryptionTargetBundle == "bundle-1")
    #expect(call.contact == "user@example.com")
    #expect(call.otpType == .email)
    #expect(call.sessionKey.hasPrefix("rain-turnkey-"))
    // A signup creates ONE wallet carrying both chain families atomically (one seed).
    let signupAccounts = try #require(turnkey.completeOtpSignupAccounts.first)
    #expect(signupAccounts.map(\.addressFormat) == [.address_format_ethereum, .address_format_solana])
    // With nothing previously selected, the vendor auto-selects — no explicit activation.
    #expect(turnkey.selectStoredSessionCalls.isEmpty)
    #expect(turnkey.selectedStoredSessionKey == call.sessionKey)
    // Both chain families already provisioned — nothing to create or derive.
    #expect(turnkey.createWalletCalls.isEmpty)
    #expect(turnkey.addAccountsCalls.isEmpty)
    #expect(controller.currentAuthState() == .authenticated)
  }

  @Test("a wrong code leaves an already-active session untouched")
  func testWrongCodeKeepsExistingSession() async throws {
    // Regression guard: clearing the stored session before the code is verified logged out a
    // user who mistyped, with no way back (verifyOtp consumes the code).
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    turnkey.completeOtpError = TurnkeySwiftError.failedToVerifyOtp(
      underlying: TurnkeyRequestError.apiError(statusCode: 401, payload: nil)
    )
    let controller = makeController(turnkey: turnkey)
    try await controller.sendLoginCode(to: .email("user@example.com"))

    await #expect(throws: RainError.invalidLoginCode) {
      try await controller.confirmLoginCode("999999")
    }

    #expect(turnkey.clearStoredSessionCalls.isEmpty)
    #expect(turnkey.session != nil)
    #expect(controller.currentAuthState() == .authenticated)
    #expect(controller.hasActiveSession())
  }

  @Test("a successful login over a live session activates the new key and drops only the old one")
  func testReloginSupersedesPreviousSession() async throws {
    let turnkey = MockTurnkey(
      wallets: [MockTurnkey.dualCurveWallet()],
      session: MockTurnkey.defaultSession()
    )
    let previousKey = try #require(turnkey.selectedStoredSessionKey)
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .email("other@example.com"))
    try await controller.confirmLoginCode("123456")

    let attemptKey = try #require(turnkey.completeOtpCalls.first?.sessionKey)
    // The vendor keeps the old session selected, so the new one is activated explicitly...
    #expect(turnkey.selectStoredSessionCalls == [attemptKey])
    #expect(turnkey.selectedStoredSessionKey == attemptKey)
    // ...and only the superseded key is purged — never the one just logged in under.
    #expect(turnkey.clearStoredSessionCalls == [previousKey])
    #expect(controller.hasActiveSession())
  }

  @Test("confirmLoginCode derives the missing Solana account from the existing wallet's seed")
  func testConfirmProvisionsMissingWallets() async throws {
    let turnkey = MockTurnkey(
      wallets: [MockTurnkey.defaultWallet()], // Ethereum account only
      session: nil
    )
    turnkey.onCompleteOtp = { turnkey.session = MockTurnkey.defaultSession() }
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .email("user@example.com"))
    try await controller.confirmLoginCode("123456")

    // Never a second wallet (a second seed to back up) — the account is derived on the
    // existing wallet.
    #expect(turnkey.createWalletCalls.isEmpty)
    #expect(turnkey.addAccountsCalls.count == 1)
    let call = try #require(turnkey.addAccountsCalls.first)
    #expect(call.walletId == "wallet-id")
    #expect(call.accounts.count == 1)
    #expect(call.accounts.first?.addressFormat == .address_format_solana)
    #expect(call.accounts.first?.curve == .curve_ed25519)
  }

  @Test("confirmLoginCode with no wallet at all creates one wallet with both accounts")
  func testConfirmCreatesSingleDualAccountWallet() async throws {
    // An account created outside the signup flow (or predating atomic provisioning).
    let turnkey = MockTurnkey(wallets: [], session: nil)
    turnkey.onCompleteOtp = { turnkey.session = MockTurnkey.defaultSession() }
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .email("user@example.com"))
    try await controller.confirmLoginCode("123456")

    #expect(turnkey.createWalletCalls.count == 1)
    let call = try #require(turnkey.createWalletCalls.first)
    #expect(call.accounts.map(\.addressFormat) == [.address_format_ethereum, .address_format_solana])
    #expect(turnkey.addAccountsCalls.isEmpty)
  }

  @Test("a vendor auth error surfaces as a mapped RainError, never raw")
  func testAuthErrorMapping() async {
    let turnkey = MockTurnkey(session: nil)
    turnkey.sendOtpError = TurnkeySwiftError.invalidSession
    let controller = makeController(turnkey: turnkey)

    do {
      try await controller.sendLoginCode(to: .email("user@example.com"))
      Issue.record("Expected an error")
    } catch let error as RainError {
      #expect(error == .tokenExpired)
    } catch {
      Issue.record("Expected RainError, got \(error)")
    }
  }

  @Test("a configuration mismatch makes every auth call throw invalidConfig")
  func testConfigurationErrorPropagates() async {
    let controller = makeController(
      turnkey: MockTurnkey(session: nil),
      configurationError: .invalidConfig(details: "mismatch")
    )

    await #expect(throws: RainError.invalidConfig(details: "mismatch")) {
      try await controller.sendLoginCode(to: .email("user@example.com"))
    }
  }

  // MARK: - State & session restore

  @Test("authState maps the vendor state to the Rain enum")
  func testAuthStateMapping() {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)
    #expect(controller.currentAuthState() == .unauthenticated)

    turnkey.session = MockTurnkey.defaultSession()
    turnkey.authState = .authenticated
    #expect(controller.currentAuthState() == .authenticated)
  }

  @Test("hasActiveSession is true only for an unexpired session")
  func testHasActiveSession() {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey)
    #expect(controller.hasActiveSession())

    turnkey.session = MockTurnkey.expiredSession()
    #expect(!controller.hasActiveSession())

    turnkey.session = nil
    #expect(!controller.hasActiveSession())
  }

  @Test("awaitSessionRestore backfills a missing account family on a restored session")
  func testRestoreBackfillsMissingAccounts() async throws {
    // A login that died between session storage and provisioning leaves a live session with an
    // EVM-only wallet; the restore path must repair it, since the OTP flow will be skipped.
    let turnkey = MockTurnkey(wallets: [MockTurnkey.defaultWallet()])
    let controller = makeController(turnkey: turnkey)

    await controller.awaitSessionRestore(timeout: 1)

    #expect(turnkey.addAccountsCalls.count == 1)
    #expect(turnkey.addAccountsCalls.first?.walletId == "wallet-id")
    #expect(turnkey.createWalletCalls.isEmpty)
  }

  @Test("awaitSessionRestore provisions nothing without a session or when accounts are complete")
  func testRestoreProvisionsOnlyWhenNeeded() async {
    let noSession = MockTurnkey(session: nil)
    await makeController(turnkey: noSession).awaitSessionRestore(timeout: 0.2)
    #expect(noSession.addAccountsCalls.isEmpty && noSession.createWalletCalls.isEmpty)

    let complete = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()])
    await makeController(turnkey: complete).awaitSessionRestore(timeout: 1)
    #expect(complete.addAccountsCalls.isEmpty && complete.createWalletCalls.isEmpty)
  }

  @Test("logout clears the stored session and the pending OTP")
  func testLogout() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey)
    try await controller.sendLoginCode(to: .email("user@example.com"))

    await controller.logout()

    #expect(turnkey.clearStoredSessionCallCount == 1)
    // The mock flips live state from a main-actor Task like the vendor; logout must have waited.
    #expect(!controller.hasActiveSession())
    #expect(controller.currentAuthState() == .unauthenticated)
    await #expect(throws: RainError.self) {
      try await controller.confirmLoginCode("123456") // pending OTP was dropped
    }
  }

  // MARK: - SMS OTP

  @Test("sendLoginCode to a phone number starts an SMS OTP")
  func testSendLoginCodeSms() async throws {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .phone("+15551234567"))

    #expect(turnkey.sendOtpCalls == [.init(contact: "+15551234567", otpType: .sms)])
  }

  @Test("confirmLoginCode completes an SMS challenge with the SMS type")
  func testConfirmSmsLoginCode() async throws {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()], session: nil)
    turnkey.onCompleteOtp = { turnkey.session = MockTurnkey.defaultSession() }
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .phone("+15551234567"))
    try await controller.confirmLoginCode("123456")

    let call = try #require(turnkey.completeOtpCalls.first)
    #expect(call.contact == "+15551234567")
    #expect(call.otpType == .sms)
  }

  // MARK: - Contact normalization

  @Test("sendLoginCode normalizes phone formatting down to E.164 before anything is sent")
  func testPhoneNormalization() async throws {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .phone(" +1 (555) 123-45.67 "))

    // The normalized string is the account identity — identical rule on Android.
    #expect(turnkey.sendOtpCalls == [.init(contact: "+15551234567", otpType: .sms)])
  }

  @Test("confirmLoginCode completes with the normalized contact, not the raw input")
  func testConfirmUsesNormalizedContact() async throws {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()], session: nil)
    turnkey.onCompleteOtp = { turnkey.session = MockTurnkey.defaultSession() }
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .phone("+1 555 123 4567"))
    try await controller.confirmLoginCode("123456")

    #expect(turnkey.completeOtpCalls.first?.contact == "+15551234567")
  }

  @Test("an email is trimmed before it is sent")
  func testEmailTrimmed() async throws {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(to: .email("  user@example.com\n"))

    #expect(turnkey.sendOtpCalls == [.init(contact: "user@example.com", otpType: .email)])
  }

  @Test(
    "an invalid contact throws invalidConfig locally, before anything is sent",
    arguments: [
      TurnkeyLoginContact.phone("5551234567"),      // no leading +: the country can't be guessed
      TurnkeyLoginContact.phone("+1555"),           // too short
      TurnkeyLoginContact.phone("+1555abc4567"),    // letters
      TurnkeyLoginContact.email("not-an-email"),    // no @
    ]
  )
  func testInvalidContactFailsFast(contact: TurnkeyLoginContact) async {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)

    await #expect(throws: RainError.self) {
      try await controller.sendLoginCode(to: contact)
    }
    #expect(turnkey.sendOtpCalls.isEmpty)
  }

  @Test("contact verification attaches the normalized phone, not the raw input")
  func testContactVerificationNormalizes() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey)

    try await controller.sendContactVerificationCode(to: .phone("+1 (555) 123-4567"))
    try await controller.confirmContactVerification("123456")

    #expect(turnkey.sendOtpCalls.first?.contact == "+15551234567")
    #expect(turnkey.setUserPhoneNumberCalls.map(\.contact) == ["+15551234567"])
  }

  // MARK: - Passkeys

  @MainActor
  @Test("passkey login on a fresh install auto-selects the vendor's default-key session")
  func testPasskeyLoginFreshInstall() async throws {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()], session: nil)
    turnkey.onPasskeyAuth = {
      turnkey.session = MockTurnkey.defaultSession()
      turnkey.authState = .authenticated
    }
    let controller = makeController(turnkey: turnkey, rpId: "passkeys.rain.xyz")

    try await controller.loginWithPasskey(anchor: ASPresentationAnchor())

    #expect(turnkey.loginWithPasskeyCallCount == 1)
    // Nothing was selected, so the vendor auto-selected — no explicit activation.
    #expect(turnkey.selectStoredSessionCalls.isEmpty)
    #expect(turnkey.selectedStoredSessionKey == MockTurnkey.passkeyDefaultSessionKey)
    // The stale-default-key pre-purge is storage-only and touched no live state.
    #expect(turnkey.clearStoredSessionCalls == [MockTurnkey.passkeyDefaultSessionKey])
    #expect(controller.hasActiveSession())
  }

  @MainActor
  @Test("passkey login over a live OTP session activates the default key and drops the old one")
  func testPasskeyLoginOverOtpSession() async throws {
    let turnkey = MockTurnkey(
      wallets: [MockTurnkey.dualCurveWallet()],
      session: MockTurnkey.defaultSession() // selected under "previous-session-key"
    )
    let controller = makeController(turnkey: turnkey, rpId: "passkeys.rain.xyz")

    try await controller.loginWithPasskey(anchor: ASPresentationAnchor())

    // The vendor kept the old session selected, so the passkey session (always under the
    // default key) is activated explicitly, then the superseded key is purged.
    #expect(turnkey.selectStoredSessionCalls == [MockTurnkey.passkeyDefaultSessionKey])
    #expect(turnkey.selectedStoredSessionKey == MockTurnkey.passkeyDefaultSessionKey)
    #expect(turnkey.clearStoredSessionCalls == [
      MockTurnkey.passkeyDefaultSessionKey, // storage-only pre-purge of the stale default key
      "previous-session-key",               // the superseded session
    ])
  }

  @MainActor
  @Test("passkey login and signup over a live passkey session are refused before the ceremony",
        arguments: [true, false])
  func testPasskeyOverLivePasskeySessionRefusedUpFront(signup: Bool) async throws {
    // The vendor stores the session LAST, so letting the ceremony run would mint a passkey (and
    // for signup an account) only to fail on the occupied default key. Refuse before Face ID.
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()], session: MockTurnkey.defaultSession())
    turnkey.selectedStoredSessionKey = MockTurnkey.passkeyDefaultSessionKey
    turnkey.storedSessionKeys = [MockTurnkey.passkeyDefaultSessionKey]
    let controller = makeController(turnkey: turnkey, rpId: "passkeys.rain.xyz")

    await #expect(throws: RainError.invalidConfig(details: "")) {
      if signup {
        try await controller.signUpWithPasskey(anchor: ASPresentationAnchor())
      } else {
        try await controller.loginWithPasskey(anchor: ASPresentationAnchor())
      }
    }

    #expect(turnkey.loginWithPasskeyCallCount == 0)
    #expect(turnkey.signUpWithPasskeyCallCount == 0)
    #expect(turnkey.clearStoredSessionCalls.isEmpty)
    #expect(turnkey.session != nil)
    #expect(controller.hasActiveSession())
  }

  @MainActor
  @Test("an expired session left under the selected default key is purged and passkey login proceeds")
  func testPasskeyLoginOverExpiredPasskeySessionProceeds() async throws {
    let turnkey = MockTurnkey(
      wallets: [MockTurnkey.dualCurveWallet()], session: MockTurnkey.session(expiringIn: -60)
    )
    turnkey.selectedStoredSessionKey = MockTurnkey.passkeyDefaultSessionKey
    turnkey.storedSessionKeys = [MockTurnkey.passkeyDefaultSessionKey]
    turnkey.onPasskeyAuth = {
      turnkey.session = MockTurnkey.defaultSession()
      turnkey.authState = .authenticated
    }
    let controller = makeController(turnkey: turnkey, rpId: "passkeys.rain.xyz")

    try await controller.loginWithPasskey(anchor: ASPresentationAnchor())

    #expect(turnkey.loginWithPasskeyCallCount == 1)
    #expect(turnkey.clearStoredSessionCalls.first == MockTurnkey.passkeyDefaultSessionKey)
    #expect(controller.hasActiveSession())
  }

  @MainActor
  @Test("passkey signup provisions one dual-account wallet atomically")
  func testPasskeySignupProvisionsAtomically() async throws {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()], session: nil)
    turnkey.onPasskeyAuth = {
      turnkey.session = MockTurnkey.defaultSession()
      turnkey.authState = .authenticated
    }
    let controller = makeController(turnkey: turnkey, rpId: "passkeys.rain.xyz")

    try await controller.signUpWithPasskey(anchor: ASPresentationAnchor())

    #expect(turnkey.signUpWithPasskeyCallCount == 1)
    let accounts = try #require(turnkey.signUpPasskeyAccounts.first)
    #expect(accounts.map(\.addressFormat) == [.address_format_ethereum, .address_format_solana])
    // Atomic provisioning at signup — nothing left for the backfill to do.
    #expect(turnkey.createWalletCalls.isEmpty)
    #expect(turnkey.addAccountsCalls.isEmpty)
  }

  @MainActor
  @Test("passkey calls without a configured relying-party domain throw invalidConfig")
  func testPasskeyWithoutRpIdThrowsInvalidConfig() async {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey) // rpId: nil

    let anchor = ASPresentationAnchor()
    await #expect(throws: RainError.self) {
      try await controller.loginWithPasskey(anchor: anchor)
    }
    await #expect(throws: RainError.self) {
      try await controller.signUpWithPasskey(anchor: anchor)
    }
    await #expect(throws: RainError.self) {
      try await controller.addPasskey(anchor: anchor)
    }
    #expect(turnkey.loginWithPasskeyCallCount == 0)
    #expect(turnkey.signUpWithPasskeyCallCount == 0)
    #expect(turnkey.addPasskeyCalls.isEmpty)
  }

  @MainActor
  @Test("addPasskey registers an authenticator against the configured domain")
  func testAddPasskeyPassesRpId() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey, rpId: "passkeys.rain.xyz")

    try await controller.addPasskey(anchor: ASPresentationAnchor())

    #expect(turnkey.addPasskeyCalls == ["passkeys.rain.xyz"])
  }

  // MARK: - Contact verification (attach a login contact)

  @Test("sendContactVerificationCode requires an active session")
  func testContactVerificationRequiresSession() async {
    let controller = makeController(turnkey: MockTurnkey(session: nil))

    await #expect(throws: RainError.tokenExpired) {
      try await controller.sendContactVerificationCode(to: .email("new@example.com"))
    }
  }

  @Test("confirmContactVerification attaches a verified email to the current account")
  func testAttachEmailContact() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    turnkey.stubbedOtpChallenge = OtpChallenge(otpId: "otp-9", encryptionTargetBundle: "bundle-9")
    let controller = makeController(turnkey: turnkey)

    try await controller.sendContactVerificationCode(to: .email("new@example.com"))
    try await controller.confirmContactVerification("123456")

    #expect(turnkey.sendOtpCalls == [.init(contact: "new@example.com", otpType: .email)])
    #expect(turnkey.verifyOtpTokenCalls == [
      .init(otpId: "otp-9", otpCode: "123456", otpEncryptionTargetBundle: "bundle-9")
    ])
    // The token is what marks the contact VERIFIED — a login method, not just profile data.
    #expect(turnkey.setUserEmailCalls == [
      .init(contact: "new@example.com", verificationToken: turnkey.stubbedVerificationToken)
    ])
    #expect(turnkey.setUserPhoneNumberCalls.isEmpty)
    // No login happened: the session machinery was never touched.
    #expect(turnkey.completeOtpCalls.isEmpty)
    #expect(turnkey.clearStoredSessionCalls.isEmpty)
  }

  @Test("confirmContactVerification attaches a verified phone number")
  func testAttachPhoneContact() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey)

    try await controller.sendContactVerificationCode(to: .phone("+15551234567"))
    try await controller.confirmContactVerification("123456")

    #expect(turnkey.sendOtpCalls.first?.otpType == .sms)
    #expect(turnkey.setUserPhoneNumberCalls.map(\.contact) == ["+15551234567"])
    #expect(turnkey.setUserEmailCalls.isEmpty)
  }

  @Test("a wrong contact-verification code maps to invalidLoginCode and keeps the challenge")
  func testWrongContactVerificationCodeIsRetryable() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    turnkey.verifyOtpTokenError = TurnkeySwiftError.failedToVerifyOtp(
      underlying: TurnkeyRequestError.apiError(statusCode: 401, payload: nil)
    )
    let controller = makeController(turnkey: turnkey)
    try await controller.sendContactVerificationCode(to: .email("new@example.com"))

    await #expect(throws: RainError.invalidLoginCode) {
      try await controller.confirmContactVerification("999999")
    }

    // The challenge survives the wrong code: a retype succeeds without a new send.
    turnkey.verifyOtpTokenError = nil
    try await controller.confirmContactVerification("123456")
    #expect(turnkey.setUserEmailCalls.map(\.contact) == ["new@example.com"])
  }

  // MARK: - Key export

  @Test("exportMnemonic exports the account's single wallet seed")
  func testExportMnemonic() async throws {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()])
    let controller = makeController(turnkey: turnkey)

    let phrase = try await controller.exportMnemonic()

    #expect(phrase == turnkey.stubbedMnemonic)
    #expect(turnkey.exportMnemonicCalls == ["wallet-id"])
    // Wallets were already loaded; no extra refresh round-trip.
    #expect(turnkey.refreshWalletsCallCount == 0)
  }

  @Test("exportMnemonic refreshes an empty wallet cache before resolving the wallet")
  func testExportMnemonicRefreshesWhenEmpty() async throws {
    let turnkey = MockTurnkey(wallets: [])
    turnkey.onRefreshWallets = { turnkey.wallets = [MockTurnkey.dualCurveWallet()] }
    let controller = makeController(turnkey: turnkey)

    _ = try await controller.exportMnemonic()

    #expect(turnkey.refreshWalletsCallCount == 1)
    #expect(turnkey.exportMnemonicCalls == ["wallet-id"])
  }

  @Test("exportMnemonic anchors on the wallet holding the Ethereum account (legacy two-seed accounts)")
  func testExportMnemonicLegacyTwoWallets() async throws {
    // Pre one-seed accounts hold two wallets/seeds. The phrase must come from the wallet whose
    // Ethereum key is in use, or it derives a different address than the exported private key.
    let turnkey = MockTurnkey(wallets: [MockTurnkey.solanaOnlyWallet(), MockTurnkey.defaultWallet()])
    let controller = makeController(turnkey: turnkey)

    _ = try await controller.exportMnemonic()

    #expect(turnkey.exportMnemonicCalls == ["wallet-id"]) // the Ethereum wallet, not "wallet-id-sol"
  }

  @Test("exportPrivateKey resolves the right account and encoding per family")
  func testExportPrivateKeyPerFamily() async throws {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()])
    let controller = makeController(turnkey: turnkey)

    let ethKey = try await controller.exportPrivateKey(family: .ethereum)
    let solKey = try await controller.exportPrivateKey(family: .solana)

    #expect(turnkey.exportAccountKeyCalls == [
      .init(address: MockTurnkey.defaultWalletAddress, encoding: .hexSecp256k1),
      .init(address: MockTurnkey.defaultSolanaAddress, encoding: .solanaBase58),
    ])
    // Ethereum keys carry the 0x prefix at the Rain boundary; Solana Base58 passes through.
    #expect(ethKey == "0x" + turnkey.stubbedExportedKey)
    #expect(solKey == turnkey.stubbedExportedKey)
  }

  @Test("exportPrivateKey for a family with no account throws a mapped error")
  func testExportPrivateKeyMissingFamily() async {
    // EVM-only wallet (predates dual-account provisioning): no Solana account to export.
    let turnkey = MockTurnkey(wallets: [MockTurnkey.defaultWallet()])
    let controller = makeController(turnkey: turnkey)

    await #expect(throws: RainError.self) {
      _ = try await controller.exportPrivateKey(family: .solana)
    }
    #expect(turnkey.exportAccountKeyCalls.isEmpty)
  }

  @Test("SolanaKeyEncoder emits the plain-Base58 keypair Solana wallets import")
  func testSolanaKeyEncoderVector() throws {
    // Known vector (PyNaCl/libsodium): priv = 0x01…20, plain Base58 of priv‖pub, NO checksum —
    // the vendor's Base58Check output is rejected by Phantom, hence this encoder.
    let encoded = try SolanaKeyEncoder.keypairBase58(
      privateKeyHex: "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"
    )
    #expect(encoded == "2Ana1pUpv2ZbMVkwF5FXapYeBEjdxDatLn7nvJkhgTSdZd8hbDHTd21as7EAsg7ypityqfsw2pMQKJcVDVcAEsd")
  }

  @Test("SolanaKeyEncoder rejects malformed key material")
  func testSolanaKeyEncoderRejectsBadInput() {
    #expect(throws: (any Error).self) {
      _ = try SolanaKeyEncoder.keypairBase58(privateKeyHex: "abcd") // not 32 bytes
    }
    #expect(throws: (any Error).self) {
      _ = try SolanaKeyEncoder.keypairBase58(privateKeyHex: "zz") // not hex
    }
  }

  @Test("export with no session surfaces a mapped RainError, never raw")
  func testExportWithoutSessionMapsError() async {
    let turnkey = MockTurnkey(wallets: [], session: nil)
    let controller = makeController(turnkey: turnkey)

    do {
      _ = try await controller.exportMnemonic()
      Issue.record("Expected exportMnemonic to throw")
    } catch {
      #expect(error is RainError)
    }
  }

  @Test("a vendor export failure surfaces as a mapped RainError, never raw")
  func testExportVendorErrorMapsError() async {
    let turnkey = MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()])
    turnkey.exportMnemonicError = TurnkeySwiftError.failedToExportWallet(
      underlying: TurnkeyRequestError.apiError(statusCode: 500, payload: nil)
    )
    let controller = makeController(turnkey: turnkey)

    do {
      _ = try await controller.exportMnemonic()
      Issue.record("Expected exportMnemonic to throw")
    } catch {
      #expect(error is RainError)
    }
  }

  // MARK: - Provider surface

  @Test("auth methods on a BYO-mode provider throw invalidConfig")
  func testByoModeGuard() async {
    let provider = TurnkeyProvider(
      config: TurnkeyConfig(organizationId: "org", authProxyConfigId: "proxy"),
      context: MockTurnkey(session: nil),
      managedAuth: nil // what a BYO construction yields
    )

    #expect(provider.currentAuthState() == .unauthenticated)
    #expect(!provider.hasActiveSession())
    await #expect(throws: RainError.self) {
      try await provider.sendLoginCode(to: .email("user@example.com"))
    }
    await #expect(throws: RainError.self) {
      _ = try await provider.exportMnemonic()
    }
    await #expect(throws: RainError.self) {
      _ = try await provider.exportPrivateKey(family: .ethereum)
    }
  }

  @Test("managed provider forwards the OTP flow to the controller")
  func testManagedProviderForwards() async throws {
    let turnkey = MockTurnkey(session: nil)
    turnkey.onCompleteOtp = { turnkey.session = MockTurnkey.defaultSession() }
    let provider = TurnkeyProvider(
      config: TurnkeyConfig(organizationId: "org", authProxyConfigId: "proxy"),
      context: turnkey,
      managedAuth: TurnkeyManagedAuthController(context: turnkey, configurationError: nil)
    )

    try await provider.sendLoginCode(to: .email("user@example.com"))
    try await provider.confirmLoginCode("123456")

    #expect(turnkey.sendOtpCalls.count == 1)
    #expect(turnkey.completeOtpCalls.count == 1)
    #expect(provider.hasActiveSession())
  }

  // MARK: - Process-wide configurator

  @Test("configure is idempotent for identical ids and errors on different ids")
  func testConfigurator() {
    // Unique ids per run: the configurator is process-global state.
    let organizationId = "org-\(UUID().uuidString)"
    let previousImpl = TurnkeyManagedConfigurator.configureImpl
    defer { TurnkeyManagedConfigurator.configureImpl = previousImpl }
    nonisolated(unsafe) var configureCalls = 0
    TurnkeyManagedConfigurator.configureImpl = { _, _, _ in configureCalls += 1 }

    #expect(TurnkeyManagedConfigurator.configure(organizationId: organizationId, authProxyConfigId: "p", rpId: nil) == nil)
    #expect(TurnkeyManagedConfigurator.configure(organizationId: organizationId, authProxyConfigId: "p", rpId: nil) == nil)
    #expect(configureCalls == 1)
    #expect(TurnkeyManagedConfigurator.configure(organizationId: "other", authProxyConfigId: "p", rpId: nil) != nil)
  }
}
