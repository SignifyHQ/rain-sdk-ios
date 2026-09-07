import SwiftUI

/// Root screen: pick a wallet provider, authenticate, initialize Rain, then open a feature.
struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: RainMetrics.s3) {
          Text("Rain SDK showcase")
            .font(RainFont.title)
            .tracking(-0.72)
            .foregroundStyle(Color.rainTextPrimary)

          modeSelector

          // Rain API credentials are independent of the wallet provider: they authenticate
          // contract / signature calls to the Rain dev API, so they live in their own card
          // shown in every mode.
          rainApiSection

          switch viewModel.mode {
          case .portal: portalSection
          case .turnkey: turnkeySection
          case .privy: privySection
          case .rainWallet: rainWalletSection
          }

          // Stays visible when the session is dead so the hidden feature grid is explained.
          if let status = sdkService.sessionStatus {
            sessionSection(status)
          }

          let sessionUsable = sdkService.sessionStatus?.health != .dead
          if viewModel.isRecovered && sessionUsable {
            chainSelector
            featureGrid
          }
          if viewModel.isRecovered {
            RainAsyncButton(title: "Clear session", kind: .destructive) {
              await viewModel.clearSession()
            }
          }

          RainStatusLog(text: viewModel.statusText)
        }
        .padding(RainMetrics.s2)
      }
      .rainScreen()
      .toolbarBackground(Color.rainInk, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }

  // MARK: - Mode selector

  private var modeSelector: some View {
    RainSegmentedTabs(
      items: WalletMode.allCases,
      selection: Binding(
        get: { viewModel.mode },
        set: { viewModel.onModeChanged($0) }
      ),
      title: { $0.rawValue },
      // Locked while a provider is resolved so the session card always describes `mode`.
      isDisabled: viewModel.isInitialized || sdkService.sessionStatus != nil
    )
  }

  // MARK: - Rain API

  private var rainApiSection: some View {
    RainSectionCard(title: "Rain API credentials") {
      RainLabeledField(title: "Rain API key", placeholder: "Enter Rain API key", text: $viewModel.rainApiKey)
      RainLabeledField(title: "Rain user ID", placeholder: "Enter Rain user ID", text: $viewModel.userId)
    }
  }

  // MARK: - Portal

  private var portalSection: some View {
    RainSectionCard(title: "Portal MPC configuration") {
      RainLabeledField(
        title: "Portal session token",
        placeholder: "Enter session token",
        text: $viewModel.sessionToken
      )

      RainAsyncButton(
        title: viewModel.isInitialized ? "SDK initialized" : "Initialize SDK",
        enabled: viewModel.canInitializePortal,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.initializeSdk()
      }
    }
  }

  // MARK: - Turnkey

  private var turnkeySection: some View {
    RainSectionCard(title: "Turnkey configuration, email OTP") {
      RainLabeledField(
        title: "Parent organization ID",
        placeholder: "your-turnkey-parent-org-id",
        text: $viewModel.turnkeyOrgId
      )
      .disabled(viewModel.turnkeyOtpSent)

      RainLabeledField(
        title: "Auth proxy config ID",
        placeholder: "auth proxy config id",
        text: $viewModel.turnkeyAuthProxyConfigId
      )
      .disabled(viewModel.turnkeyOtpSent)

      RainLabeledField(title: "Email", placeholder: "you@example.com", text: $viewModel.turnkeyEmail)
        .disabled(viewModel.turnkeyOtpSent)

      RainAsyncButton(
        title: viewModel.turnkeyOtpSent ? "OTP sent" : "Init Turnkey & send OTP",
        enabled: viewModel.canSendTurnkeyOtp,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.sendTurnkeyOtp()
      }

      if viewModel.turnkeyOtpSent {
        RainLabeledField(title: "OTP code", placeholder: "123456", text: $viewModel.turnkeyOtpCode)
          .disabled(viewModel.turnkeySessionActive)

        RainAsyncButton(
          title: viewModel.turnkeySessionActive ? "Session active" : "Verify & log in",
          enabled: viewModel.canVerifyTurnkeyOtp,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.verifyTurnkeyOtp()
        }
      }

      if viewModel.turnkeySessionActive {
        RainAsyncButton(
          title: viewModel.isInitialized ? "Rain initialized" : "Initialize Rain with Turnkey",
          enabled: !viewModel.isLoading && !viewModel.isInitialized,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.initializeRainWithTurnkey()
        }
      }
    }
  }

  // MARK: - Rain Wallet

  private var rainWalletSection: some View {
    RainSectionCard(title: "Rain Wallet configuration, email login code") {
      RainLabeledField(
        title: "Organization ID",
        placeholder: "rain-issued organization id",
        text: $viewModel.rainWalletOrgId
      )
      .disabled(viewModel.rainWalletOtpSent)

      RainLabeledField(
        title: "Auth config ID",
        placeholder: "rain-issued auth config id",
        text: $viewModel.rainWalletAuthConfigId
      )
      .disabled(viewModel.rainWalletOtpSent)

      RainLabeledField(title: "Email", placeholder: "you@example.com", text: $viewModel.rainWalletEmail)
        .disabled(viewModel.rainWalletOtpSent)

      RainAsyncButton(
        title: viewModel.rainWalletOtpSent ? "Code sent" : "Init Rain Wallet & send code",
        enabled: viewModel.canSendRainWalletOtp,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.sendRainWalletOtp()
      }

      if viewModel.rainWalletOtpSent {
        RainLabeledField(title: "Login code", placeholder: "123456", text: $viewModel.rainWalletOtpCode)
          .disabled(viewModel.rainWalletSessionActive)

        RainAsyncButton(
          title: viewModel.rainWalletSessionActive ? "Session active" : "Verify & log in",
          enabled: viewModel.canVerifyRainWalletOtp,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.verifyRainWalletOtp()
        }
      }

      if viewModel.rainWalletSessionActive {
        RainAsyncButton(
          title: viewModel.isInitialized ? "Rain initialized" : "Initialize Rain with Rain Wallet",
          enabled: !viewModel.isLoading && !viewModel.isInitialized,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.initializeRainWithRainWallet()
        }
      }
    }
  }

  // MARK: - Privy

  private var privySection: some View {
    RainSectionCard(title: "Privy configuration, email OTP") {
      RainLabeledField(title: "Privy app ID", placeholder: "your-privy-app-id", text: $viewModel.privyAppId)
        .disabled(viewModel.privyOtpSent || viewModel.privySessionActive)

      RainLabeledField(
        title: "Privy app client ID",
        placeholder: "your-privy-app-client-id",
        text: $viewModel.privyAppClientId
      )
      .disabled(viewModel.privyOtpSent || viewModel.privySessionActive)

      RainLabeledField(title: "Email", placeholder: "you@example.com", text: $viewModel.privyEmail)
        .disabled(viewModel.privyOtpSent || viewModel.privySessionActive)

      RainAsyncButton(
        title: viewModel.privyOtpSent ? "OTP sent" : "Init Privy & send OTP",
        enabled: viewModel.canSendPrivyOtp,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.sendPrivyOtp()
      }

      if viewModel.privyOtpSent && !viewModel.privySessionActive {
        RainLabeledField(title: "OTP code", placeholder: "123456", text: $viewModel.privyOtpCode)

        RainAsyncButton(
          title: "Verify & log in",
          enabled: viewModel.canVerifyPrivyOtp,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.verifyPrivyOtp()
        }
      }

      if viewModel.privySessionActive {
        RainAsyncButton(
          title: viewModel.isInitialized ? "Rain initialized" : "Initialize Rain with Privy",
          enabled: !viewModel.isLoading && !viewModel.isInitialized,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.initializeRainWithPrivy()
        }
      }
    }
  }

  // MARK: - Session state

  /// `sessionState`, `refreshSession()` and, for Portal, `updateSessionToken(_:)`.
  private func sessionSection(_ status: WalletSessionStatus) -> some View {
    RainSectionCard(title: "Wallet session") {
      HStack {
        RainStatusPill(text: status.label, active: status.health == .healthy)
        Spacer()
      }
      if let detail = status.detail {
        Text(detail)
          .font(RainFont.meta)
          .tracking(-0.12)
          .foregroundStyle(Color.rainTextMuted)
      }

      // Portal's refresh goes through onSessionTokenNeeded, which needs a replacement token.
      let canRefresh = !viewModel.isLoading
        && (viewModel.mode != .portal || viewModel.canUpdatePortalToken)
      RainAsyncButton(title: "Refresh session", kind: .secondary, enabled: canRefresh) {
        await viewModel.refreshSession()
      }

      if viewModel.mode == .portal {
        Text(
          "Replacement token: \"Update token\" installs it now (updateSessionToken); "
            + "refresh and any rejected call take it via onSessionTokenNeeded."
        )
        .font(RainFont.meta)
        .tracking(-0.12)
        .lineSpacing(4)
        .foregroundStyle(Color.rainTextMuted)

        RainLabeledField(
          title: "Replacement session token",
          placeholder: "Enter a freshly minted token",
          text: $viewModel.replacementPortalToken
        )

        RainAsyncButton(title: "Update token", kind: .secondary, enabled: viewModel.canUpdatePortalToken) {
          await viewModel.updatePortalSessionToken()
        }
      }
    }
  }

  // MARK: - Chain selector

  private var chainSelector: some View {
    VStack(alignment: .leading, spacing: RainMetrics.s1) {
      RainSectionLabel(text: "Active wallet")

      Menu {
        ForEach(viewModel.availableChains) { chain in
          Button(chain.displayName) { sdkService.selectedChain = chain }
        }
      } label: {
        RainSelectorRow {
          Text(sdkService.selectedChain.displayName)
        }
      }
    }
    // Turnkey and Privy hold a Solana account; Portal is EVM-only.
    .onAppear { viewModel.normalizeSelectedChain() }
    .onChange(of: sdkService.selectedChain) { viewModel.normalizeSelectedChain() }
  }

  // MARK: - Feature grid

  private var featureGrid: some View {
    VStack(alignment: .leading, spacing: RainMetrics.s1) {
      RainSectionLabel(text: "SDK features")

      LazyVGrid(
        columns: [GridItem(spacing: RainMetrics.s1), GridItem(spacing: RainMetrics.s1)],
        spacing: RainMetrics.s1
      ) {
        RainFeatureTile(icon: .walletQR, title: "Wallet & QR") { WalletInfoView() }
        RainFeatureTile(icon: .balances, title: "Balances") { BalancesView() }
        RainFeatureTile(icon: .sendTokens, title: "Send tokens") { SendTokensView() }
        RainFeatureTile(icon: .withdraw, title: "Withdraw") { CollateralWithdrawView() }
        RainFeatureTile(icon: .authPull, title: "Auth pull") { AuthPullView() }
        RainFeatureTile(icon: .history, title: "History") { TransactionHistoryView() }
      }
    }
  }
}

#Preview {
  HomeView()
}
