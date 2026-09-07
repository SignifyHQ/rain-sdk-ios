import Testing
import Foundation
import TurnkeySwift
@_spi(RainAdapter) @testable import RainCore
@testable import RainTurnkey

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

  @Test("confirmLoginCode clears any stored session and completes the OTP with the stashed challenge")
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

    #expect(turnkey.clearStoredSessionCallCount == 1)
    #expect(turnkey.completeOtpCalls == [.init(
      otpId: "otp-1",
      otpCode: "123456",
      otpEncryptionTargetBundle: "bundle-1",
      contact: "user@example.com",
      otpType: .email
    )])
    // Both chain families already provisioned — nothing to create.
    #expect(turnkey.createWalletCalls.isEmpty)
    #expect(controller.authState == .authenticated)
  }

  @Test("confirmLoginCode provisions the missing Solana wallet for an EVM-only account")
  func testConfirmProvisionsMissingWallets() async throws {
    let turnkey = MockTurnkey(
      wallets: [MockTurnkey.defaultWallet()], // Ethereum account only
      session: nil
    )
    turnkey.onCompleteOtp = { turnkey.session = MockTurnkey.defaultSession() }
    let controller = makeController(turnkey: turnkey)

    try await controller.sendLoginCode(email: "user@example.com")
    try await controller.confirmLoginCode("123456")

    #expect(turnkey.createWalletCalls.count == 1)
    let call = try #require(turnkey.createWalletCalls.first)
    #expect(call.accounts.first?.addressFormat == .address_format_solana)
    #expect(call.accounts.first?.curve == .curve_ed25519)
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
