import Testing
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
    configurationError: RainSDKError? = nil
  ) -> TurnkeyManagedAuthController {
    TurnkeyManagedAuthController(context: turnkey, configurationError: configurationError)
  }

  // MARK: - OTP flow

  @Test("sendLoginCode starts an email OTP for the given address")
  func testSendLoginCode() async throws {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(email: "user@example.com")

    #expect(turnkey.sendOtpCalls == [.init(contact: "user@example.com", otpType: .email)])
  }

  @Test("confirmLoginCode without a prior sendLoginCode throws invalidConfig")
  func testConfirmWithoutSend() async {
    let controller = makeController(turnkey: MockTurnkey(session: nil))

    await #expect(throws: RainSDKError.self) {
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

    try await controller.sendLoginCode(email: "user@example.com")
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
    #expect(controller.authState == .authenticated)
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
    try await controller.sendLoginCode(email: "user@example.com")

    await #expect(throws: RainSDKError.invalidLoginCode) {
      try await controller.confirmLoginCode("999999")
    }

    #expect(turnkey.clearStoredSessionCalls.isEmpty)
    #expect(turnkey.session != nil)
    #expect(controller.authState == .authenticated)
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

    try await controller.sendLoginCode(email: "other@example.com")
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

    try await controller.sendLoginCode(email: "user@example.com")
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

    try await controller.sendLoginCode(email: "user@example.com")
    try await controller.confirmLoginCode("123456")

    #expect(turnkey.createWalletCalls.count == 1)
    let call = try #require(turnkey.createWalletCalls.first)
    #expect(call.accounts.map(\.addressFormat) == [.address_format_ethereum, .address_format_solana])
    #expect(turnkey.addAccountsCalls.isEmpty)
  }

  @Test("a vendor auth error surfaces as a mapped RainSDKError, never raw")
  func testAuthErrorMapping() async {
    let turnkey = MockTurnkey(session: nil)
    turnkey.sendOtpError = TurnkeySwiftError.invalidSession
    let controller = makeController(turnkey: turnkey)

    do {
      try await controller.sendLoginCode(email: "user@example.com")
      Issue.record("Expected an error")
    } catch let error as RainSDKError {
      #expect(error == .tokenExpired)
    } catch {
      Issue.record("Expected RainSDKError, got \(error)")
    }
  }

  @Test("a configuration mismatch makes every auth call throw invalidConfig")
  func testConfigurationErrorPropagates() async {
    let controller = makeController(
      turnkey: MockTurnkey(session: nil),
      configurationError: .invalidConfig(details: "mismatch")
    )

    await #expect(throws: RainSDKError.invalidConfig(details: "mismatch")) {
      try await controller.sendLoginCode(email: "user@example.com")
    }
  }

  // MARK: - State & session restore

  @Test("authState maps the vendor state to the Rain enum")
  func testAuthStateMapping() {
    let turnkey = MockTurnkey(session: nil)
    let controller = makeController(turnkey: turnkey)
    #expect(controller.authState == .unauthenticated)

    turnkey.session = MockTurnkey.defaultSession()
    turnkey.authState = .authenticated
    #expect(controller.authState == .authenticated)
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

  @Test("logout clears the stored session and the pending OTP")
  func testLogout() async throws {
    let turnkey = MockTurnkey(session: MockTurnkey.defaultSession())
    let controller = makeController(turnkey: turnkey)
    try await controller.sendLoginCode(email: "user@example.com")

    controller.logout()

    #expect(turnkey.clearStoredSessionCallCount == 1)
    await #expect(throws: RainSDKError.self) {
      try await controller.confirmLoginCode("123456") // pending OTP was dropped
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

    #expect(provider.authState == .unauthenticated)
    #expect(!provider.hasActiveSession())
    await #expect(throws: RainSDKError.self) {
      try await provider.sendLoginCode(email: "user@example.com")
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

    try await provider.sendLoginCode(email: "user@example.com")
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
    TurnkeyManagedConfigurator.configureImpl = { _, _ in configureCalls += 1 }

    #expect(TurnkeyManagedConfigurator.configure(organizationId: organizationId, authProxyConfigId: "p") == nil)
    #expect(TurnkeyManagedConfigurator.configure(organizationId: organizationId, authProxyConfigId: "p") == nil)
    #expect(configureCalls == 1)
    #expect(TurnkeyManagedConfigurator.configure(organizationId: "other", authProxyConfigId: "p") != nil)
  }
}
