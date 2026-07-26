import Foundation
import RainCore

/// Wallet provider the demo initializes with.
enum WalletMode: String, CaseIterable, Identifiable {
  case portal = "Portal MPC"
  case turnkey = "Turnkey"
  case privy = "Privy"

  var id: String { rawValue }
}

/// Drives the home screen: provider selection, credentials, auth, and SDK initialization.
@MainActor
final class HomeViewModel: ObservableObject {
  private let session: RainSDKService

  @Published var mode: WalletMode = .turnkey

  // Rain API credentials — independent of the wallet provider.
  @Published var rainApiKey = "" { didSet { pushRainApiCredentials() } }
  @Published var userId = "" { didSet { pushRainApiCredentials() } }

  // Portal
  @Published var sessionToken = ""

  // Turnkey
  @Published var turnkeyOrgId = ""
  @Published var turnkeyAuthProxyConfigId = ""
  @Published var turnkeyEmail = ""
  @Published var turnkeyOtpCode = ""
  @Published private(set) var turnkeyOtpId: String?
  @Published private(set) var turnkeySessionActive = false
  private var turnkeyOtpEncryptionBundle: String?

  // Privy
  @Published var privyAppId = ""
  @Published var privyAppClientId = ""
  @Published var privyEmail = ""
  @Published var privyOtpCode = ""
  @Published private(set) var privyOtpSent = false
  @Published private(set) var privySessionActive = false

  @Published private(set) var isInitialized = false
  /// True once the wallet is ready to use — the feature grid appears.
  @Published private(set) var isRecovered = false
  @Published private(set) var isLoading = false
  @Published private(set) var statusText = "Ready"

  init() {
    self.session = .shared
    isInitialized = session.isInitialized
  }

  var selectedChain: WalletChain {
    get { session.selectedChain }
    set { session.selectedChain = newValue }
  }

  /// Portal holds no Solana account, so it only ever operates on the EVM chains.
  var availableChains: [WalletChain] {
    WalletChain.allCases.filter { mode != .portal || !$0.isSolana }
  }

  func onModeChanged(_ mode: WalletMode) {
    guard !isInitialized else { return }
    SampleLog.d("Home", "mode changed: \(mode.rawValue)")
    self.mode = mode
  }

  private func pushRainApiCredentials() {
    session.configureRainApi(apiKey: rainApiKey, userId: userId)
  }

  // MARK: - Portal

  var canInitializePortal: Bool {
    !sessionToken.trimmed.isEmpty && !isInitialized && !isLoading
  }

  func initializeSdk() async {
    guard canInitializePortal else { return }
    let token = sessionToken.trimmed
    SampleLog.i("Portal.init", "calling initializePortal sessionToken=\(SampleLog.maskToken(token))")
    isLoading = true
    statusText = "Initializing Portal..."

    do {
      try await session.initializePortal(sessionToken: token)

      // A freshly-created Portal client has no wallet; generate one before any screen asks
      // for an address. MPC keygen takes a few seconds on first run.
      statusText = "Setting up wallet..."
      let createdWallet = try await session.ensurePortalWallet()

      SampleLog.i(
        "Portal.init",
        "success — isInitialized=\(session.isInitialized) createdWallet=\(createdWallet)"
      )
      // Recovery (the Portal backup share) is no longer available via the Rain API, so a
      // successful init goes straight to the feature grid instead of gating on recovery.
      isInitialized = session.isInitialized
      isRecovered = true
      statusText = "SDK Initialized Successfully!"
    } catch {
      SampleLog.e("Portal.init", "failed: \(error.localizedDescription)")
      isInitialized = false
      statusText = "Error: \(error.localizedDescription)"
    }
    isLoading = false
  }

  // MARK: - Turnkey

  var canSendTurnkeyOtp: Bool {
    !turnkeyOrgId.trimmed.isEmpty
      && !turnkeyAuthProxyConfigId.trimmed.isEmpty
      && !turnkeyEmail.trimmed.isEmpty
      && !isLoading
      && turnkeyOtpId == nil
  }

  var canVerifyTurnkeyOtp: Bool {
    !turnkeyOtpCode.trimmed.isEmpty && !isLoading && !turnkeySessionActive
  }

  func sendTurnkeyOtp() async {
    guard canSendTurnkeyOtp else {
      statusText = "Org ID, Auth Proxy Config ID, and Email are required"
      return
    }
    let email = turnkeyEmail.trimmed
    SampleLog.i("Turnkey.otpInit", "starting email-OTP flow email=\(SampleLog.maskEmail(email))")
    isLoading = true
    statusText = "Initializing Turnkey..."

    do {
      try TurnkeyAuthSample.configure(
        organizationId: turnkeyOrgId.trimmed,
        authProxyConfigId: turnkeyAuthProxyConfigId.trimmed
      )

      // Turnkey restores a valid session from the Keychain. Only reuse it when it provably
      // belongs to the email being logged in — otherwise entering a different email would
      // silently continue as the previous user. On mismatch, log out and run the full OTP flow.
      if TurnkeyAuthSample.hasActiveSession() {
        let sessionEmail = await TurnkeyAuthSample.activeSessionEmail()
        if let sessionEmail, sessionEmail.caseInsensitiveCompare(email) == .orderedSame {
          SampleLog.i("Turnkey.otpInit", "existing session restored for this email — skipping OTP")
          turnkeySessionActive = true
          statusText = "Existing Turnkey session restored — initialize Rain to continue"
          isLoading = false
          return
        }
        SampleLog.w(
          "Turnkey.otpInit",
          "restored session belongs to \(SampleLog.maskEmail(sessionEmail)), "
          + "not \(SampleLog.maskEmail(email)) — logging out"
        )
        TurnkeyAuthSample.logout()
      }

      statusText = "Sending OTP to \(email)..."
      let result = try await TurnkeyAuthSample.sendEmailOtp(email: email)
      turnkeyOtpId = result.otpId
      turnkeyOtpEncryptionBundle = result.otpEncryptionTargetBundle
      statusText = "OTP sent — check your email"
      SampleLog.i("Turnkey.otpInit", "OTP sent")
    } catch {
      SampleLog.e("Turnkey.otpInit", "failed: \(error.localizedDescription)")
      statusText = "Turnkey OTP init failed: \(error.localizedDescription)"
    }
    isLoading = false
  }

  func verifyTurnkeyOtp() async {
    guard let otpId = turnkeyOtpId, let bundle = turnkeyOtpEncryptionBundle else {
      statusText = "Send OTP first"
      return
    }
    guard canVerifyTurnkeyOtp else {
      statusText = "OTP code required"
      return
    }

    SampleLog.i("Turnkey.otpVerify", "verifying OTP")
    isLoading = true
    statusText = "Verifying OTP..."

    do {
      try await TurnkeyAuthSample.verifyEmailOtp(
        otpId: otpId,
        otpCode: turnkeyOtpCode.trimmed,
        otpEncryptionTargetBundle: bundle,
        email: turnkeyEmail.trimmed
      )
      turnkeySessionActive = true
      statusText = "Turnkey session active — initialize Rain to continue"
    } catch {
      SampleLog.e("Turnkey.otpVerify", "failed: \(error.localizedDescription)")
      statusText = "OTP verification failed: \(error.localizedDescription)"
    }
    isLoading = false
  }

  func initializeRainWithTurnkey() async {
    guard turnkeySessionActive else {
      statusText = "Verify OTP first"
      return
    }
    SampleLog.i("Turnkey.rainInit", "initializing Rain w/ Turnkey (EVM + Solana)")
    isLoading = true
    statusText = "Initializing Rain with Turnkey..."

    do {
      let createdEvm = try await TurnkeyAuthSample.ensureEthereumWallet()
      let createdSolana = try await TurnkeyAuthSample.ensureSolanaWallet()
      if createdEvm || createdSolana {
        statusText = "Provisioned Turnkey wallets, initializing Rain..."
      }

      try await session.initializeTurnkey(turnkey: TurnkeyAuthSample.context)
      await logResolvedAddresses(area: "Turnkey.rainInit")
      isInitialized = session.isInitialized
      isRecovered = true
      statusText = "Rain initialized with Turnkey — wallet ready"
    } catch {
      SampleLog.e("Turnkey.rainInit", "failed: \(error.localizedDescription)")
      statusText = "Rain Turnkey init failed: \(error.localizedDescription)"
    }
    isLoading = false
  }

  // MARK: - Privy

  var canSendPrivyOtp: Bool {
    !privyAppId.trimmed.isEmpty
      && !privyAppClientId.trimmed.isEmpty
      && !privyEmail.trimmed.isEmpty
      && !isLoading
      && !privyOtpSent
      && !privySessionActive
  }

  var canVerifyPrivyOtp: Bool {
    !privyOtpCode.trimmed.isEmpty && !isLoading
  }

  func sendPrivyOtp() async {
    guard canSendPrivyOtp else {
      statusText = "App ID, App Client ID, and Email are required"
      return
    }
    let email = privyEmail.trimmed
    SampleLog.i("Privy.otpInit", "starting email-OTP flow email=\(SampleLog.maskEmail(email))")
    isLoading = true
    statusText = "Initializing Privy..."

    do {
      PrivyAuthSample.shared.initialize(
        appId: privyAppId.trimmed,
        appClientId: privyAppClientId.trimmed
      )

      // As on Turnkey: only reuse a restored session when it belongs to this email.
      if await PrivyAuthSample.shared.hasActiveSession() {
        let sessionEmail = await PrivyAuthSample.shared.activeSessionEmail()
        if let sessionEmail, sessionEmail.caseInsensitiveCompare(email) == .orderedSame {
          SampleLog.i("Privy.otpInit", "existing session restored for this email — skipping OTP")
          privySessionActive = true
          statusText = "Existing Privy session restored — initialize Rain to continue"
          isLoading = false
          return
        }
        SampleLog.w(
          "Privy.otpInit",
          "restored session belongs to \(SampleLog.maskEmail(sessionEmail)), "
          + "not \(SampleLog.maskEmail(email)) — logging out"
        )
        await PrivyAuthSample.shared.logout()
      }

      statusText = "Sending OTP to \(email)..."
      try await PrivyAuthSample.shared.sendEmailOtp(email: email)
      privyOtpSent = true
      statusText = "OTP sent — check your email"
      SampleLog.i("Privy.otpInit", "OTP sent")
    } catch {
      SampleLog.e("Privy.otpInit", "failed: \(error.localizedDescription)")
      statusText = "Privy OTP init failed: \(error.localizedDescription)"
    }
    isLoading = false
  }

  func verifyPrivyOtp() async {
    guard privyOtpSent else {
      statusText = "Send OTP first"
      return
    }
    guard canVerifyPrivyOtp else {
      statusText = "OTP code required"
      return
    }

    SampleLog.i("Privy.otpVerify", "verifying OTP")
    isLoading = true
    statusText = "Verifying OTP..."

    do {
      try await PrivyAuthSample.shared.verifyEmailOtp(
        code: privyOtpCode.trimmed,
        email: privyEmail.trimmed
      )
      privySessionActive = true
      statusText = "Privy session active — initialize Rain to continue"
    } catch {
      SampleLog.e("Privy.otpVerify", "failed: \(error.localizedDescription)")
      statusText = "OTP verification failed: \(error.localizedDescription)"
    }
    isLoading = false
  }

  func initializeRainWithPrivy() async {
    guard privySessionActive else {
      statusText = "Verify OTP first"
      return
    }
    SampleLog.i("Privy.rainInit", "initializing Rain w/ Privy")
    isLoading = true
    statusText = "Initializing Rain with Privy..."

    do {
      // Privy keeps Ethereum and Solana accounts separate, so both are provisioned.
      let createdEvm = try await PrivyAuthSample.shared.ensureEthereumWallet()
      let createdSolana = try await PrivyAuthSample.shared.ensureSolanaWallet()
      if createdEvm || createdSolana {
        statusText = "Provisioned Privy wallets, initializing Rain..."
      }

      try await session.initializePrivy(privy: PrivyAuthSample.shared.privy)
      await logResolvedAddresses(area: "Privy.rainInit")
      isInitialized = session.isInitialized
      isRecovered = true
      statusText = "Rain initialized with Privy — wallet ready"
    } catch {
      SampleLog.e("Privy.rainInit", "failed: \(error.localizedDescription)")
      statusText = "Rain Privy init failed: \(error.localizedDescription)"
    }
    isLoading = false
  }

  // MARK: - Session

  func clearSession() async {
    SampleLog.i("Home", "clearing session (provider logout + UI reset)")
    // Real logout so the next run requires fresh auth (and resume detects no session).
    TurnkeyAuthSample.logout()
    await PrivyAuthSample.shared.logout()
    session.reset()

    // Every input resets (the provider choice is kept), so the next run starts from scratch.
    rainApiKey = ""
    userId = ""
    sessionToken = ""
    turnkeyOrgId = ""
    turnkeyAuthProxyConfigId = ""
    turnkeyEmail = ""
    turnkeyOtpId = nil
    turnkeyOtpCode = ""
    turnkeyOtpEncryptionBundle = nil
    turnkeySessionActive = false
    privyAppId = ""
    privyAppClientId = ""
    privyEmail = ""
    privyOtpSent = false
    privyOtpCode = ""
    privySessionActive = false
    isInitialized = false
    isRecovered = false
    statusText = "Session Cleared"
  }

  /// Portal is EVM-only; force the selection back to an EVM chain so it never reads/signs on Solana.
  func normalizeSelectedChain() {
    if mode == .portal && selectedChain.isSolana {
      selectedChain = .avalancheFuji
    }
  }

  private func logResolvedAddresses(area: String) async {
    let client = try? session.requireClient()
    let evm = try? await client?.getWalletAddress(chainId: WalletChain.avalancheFuji.chainId)
    let solana = try? await client?.getWalletAddress(chainId: WalletChain.solanaDevnet.chainId)
    SampleLog.i(
      area,
      "success — isInitialized=\(session.isInitialized) evm=\(evm ?? "nil") sol=\(solana ?? "nil")"
    )
  }
}
