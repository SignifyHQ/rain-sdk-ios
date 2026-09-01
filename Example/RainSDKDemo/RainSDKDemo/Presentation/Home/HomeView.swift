import SwiftUI

/// Root screen: pick a wallet provider, authenticate, initialize Rain, then open a feature.
struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          Text("Rain SDK Showcase")
            .font(.title)
            .fontWeight(.bold)

          modeSelector

          // Rain API credentials are independent of the wallet provider: they authenticate
          // contract / signature calls to the Rain dev API, so they live in their own card
          // shown in every mode.
          rainApiSection

          switch viewModel.mode {
          case .portal: portalSection
          case .turnkey: turnkeySection
          case .privy: privySection
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
            clearSessionButton
          }

          statusSection
        }
        .padding()
      }
      .navigationTitle("Rain SDK Demo")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  // MARK: - Mode selector

  private var modeSelector: some View {
    Picker("Wallet provider", selection: Binding(
      get: { viewModel.mode },
      set: { viewModel.onModeChanged($0) }
    )) {
      ForEach(WalletMode.allCases) { mode in
        Text(mode.rawValue).tag(mode)
      }
    }
    .pickerStyle(.segmented)
    // Locked while a provider is resolved so the session card always describes `mode`.
    .disabled(viewModel.isInitialized || sdkService.sessionStatus != nil)
  }

  // MARK: - Rain API

  private var rainApiSection: some View {
    card("Rain API Credentials") {
      labeledField(title: "Rain Api-Key", placeholder: "Enter Rain Api-Key", text: $viewModel.rainApiKey)
      labeledField(title: "Rain User ID", placeholder: "Enter Rain User ID", text: $viewModel.userId)
    }
  }

  // MARK: - Portal

  private var portalSection: some View {
    card("Portal Configuration") {
      labeledField(
        title: "Portal Session Token",
        placeholder: "Enter session token",
        text: $viewModel.sessionToken
      )

      actionButton(
        title: viewModel.isInitialized ? "✅ SDK Initialized" : "Initialize SDK",
        enabled: viewModel.canInitializePortal,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.initializeSdk()
      }
    }
  }

  // MARK: - Turnkey

  private var turnkeySection: some View {
    card("Turnkey Configuration (Email OTP)") {
      labeledField(
        title: "Parent Organization ID",
        placeholder: "your-turnkey-parent-org-id",
        text: $viewModel.turnkeyOrgId
      )
      .disabled(viewModel.turnkeyOtpId != nil)

      labeledField(
        title: "Auth Proxy Config ID",
        placeholder: "auth proxy config id",
        text: $viewModel.turnkeyAuthProxyConfigId
      )
      .disabled(viewModel.turnkeyOtpId != nil)

      labeledField(title: "Email", placeholder: "you@example.com", text: $viewModel.turnkeyEmail)
        .disabled(viewModel.turnkeyOtpId != nil)

      actionButton(
        title: viewModel.turnkeyOtpId != nil ? "OTP sent" : "Init Turnkey & Send OTP",
        enabled: viewModel.canSendTurnkeyOtp,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.sendTurnkeyOtp()
      }

      if viewModel.turnkeyOtpId != nil {
        labeledField(title: "OTP Code", placeholder: "123456", text: $viewModel.turnkeyOtpCode)
          .disabled(viewModel.turnkeySessionActive)

        actionButton(
          title: viewModel.turnkeySessionActive ? "✅ Session active" : "Verify & Log In",
          enabled: viewModel.canVerifyTurnkeyOtp,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.verifyTurnkeyOtp()
        }
      }

      if viewModel.turnkeySessionActive {
        actionButton(
          title: viewModel.isInitialized ? "✅ Rain Initialized" : "Initialize Rain w/ Turnkey",
          enabled: !viewModel.isLoading && !viewModel.isInitialized,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.initializeRainWithTurnkey()
        }
      }
    }
  }

  // MARK: - Privy

  private var privySection: some View {
    card("Privy Configuration (Email OTP)") {
      labeledField(title: "Privy App ID", placeholder: "your-privy-app-id", text: $viewModel.privyAppId)
        .disabled(viewModel.privyOtpSent || viewModel.privySessionActive)

      labeledField(
        title: "Privy App Client ID",
        placeholder: "your-privy-app-client-id",
        text: $viewModel.privyAppClientId
      )
      .disabled(viewModel.privyOtpSent || viewModel.privySessionActive)

      labeledField(title: "Email", placeholder: "you@example.com", text: $viewModel.privyEmail)
        .disabled(viewModel.privyOtpSent || viewModel.privySessionActive)

      actionButton(
        title: viewModel.privyOtpSent ? "OTP sent" : "Init Privy & Send OTP",
        enabled: viewModel.canSendPrivyOtp,
        isLoading: viewModel.isLoading
      ) {
        await viewModel.sendPrivyOtp()
      }

      if viewModel.privyOtpSent && !viewModel.privySessionActive {
        labeledField(title: "OTP Code", placeholder: "123456", text: $viewModel.privyOtpCode)

        actionButton(
          title: "Verify & Log In",
          enabled: viewModel.canVerifyPrivyOtp,
          isLoading: viewModel.isLoading
        ) {
          await viewModel.verifyPrivyOtp()
        }
      }

      if viewModel.privySessionActive {
        actionButton(
          title: viewModel.isInitialized ? "✅ Rain Initialized" : "Initialize Rain w/ Privy",
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
    card("Wallet Session") {
      HStack(spacing: 8) {
        Circle()
          .fill(indicatorColor(for: status.health))
          .frame(width: 12, height: 12)
        Text(status.label)
          .font(.body)
          .fontWeight(.semibold)
      }
      if let detail = status.detail {
        Text(detail)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Portal's refresh goes through onSessionTokenNeeded, which needs a replacement token.
      let canRefresh = !viewModel.isLoading
        && (viewModel.mode != .portal || viewModel.canUpdatePortalToken)
      secondaryButton(title: "Refresh session", enabled: canRefresh) {
        await viewModel.refreshSession()
      }

      if viewModel.mode == .portal {
        Text(
          "Replacement token: \"Update token\" installs it now (updateSessionToken); "
            + "Refresh and any rejected call take it via onSessionTokenNeeded."
        )
        .font(.caption)
        .foregroundColor(.secondary)

        labeledField(
          title: "Replacement session token",
          placeholder: "Enter a freshly minted token",
          text: $viewModel.replacementPortalToken
        )

        secondaryButton(title: "Update token", enabled: viewModel.canUpdatePortalToken) {
          await viewModel.updatePortalSessionToken()
        }
      }
    }
  }

  private func indicatorColor(for health: SessionHealth) -> Color {
    switch health {
    case .healthy: return .green
    case .transitional: return .yellow
    case .dead: return .red
    case .unknown: return .gray
    }
  }

  // MARK: - Chain selector

  private var chainSelector: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Active wallet")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)

      Picker("Active wallet", selection: $sdkService.selectedChain) {
        ForEach(viewModel.availableChains) { chain in
          Text(chain.displayName).tag(chain)
        }
      }
      .pickerStyle(.menu)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(12)
      .background(Color(.systemBackground))
      .cornerRadius(8)
      .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.4)))
    }
    // Turnkey and Privy hold a Solana account; Portal is EVM-only.
    .onAppear { viewModel.normalizeSelectedChain() }
    .onChange(of: sdkService.selectedChain) { viewModel.normalizeSelectedChain() }
  }

  // MARK: - Feature grid

  private var featureGrid: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("SDK Features")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)

      LazyVGrid(columns: [GridItem(spacing: 12), GridItem(spacing: 12)], spacing: 12) {
        featureCard(emoji: "💳", label: "Wallet & QR") { WalletInfoView() }
        featureCard(emoji: "💰", label: "Balances") { BalancesView() }
        featureCard(emoji: "📤", label: "Send Tokens") { SendTokensView() }
        featureCard(emoji: "🏦", label: "Withdraw") { CollateralWithdrawView() }
        featureCard(emoji: "📜", label: "History") { TransactionHistoryView() }
      }
    }
  }

  private func featureCard<Destination: View>(
    emoji: String,
    label: String,
    @ViewBuilder destination: () -> Destination
  ) -> some View {
    NavigationLink(destination: destination()) {
      VStack(spacing: 8) {
        Text(emoji)
          .font(.system(size: 32))
        Text(label)
          .font(.subheadline)
          .fontWeight(.medium)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(20)
      .background(Color.accentColor.opacity(0.12))
      .foregroundColor(.primary)
      .cornerRadius(12)
    }
    .buttonStyle(.plain)
  }

  // MARK: - Session

  private var clearSessionButton: some View {
    Button {
      hideKeyboard()
      Task { await viewModel.clearSession() }
    } label: {
      Text("Clear Session")
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(12)
    }
  }

  private var statusSection: some View {
    Text("Status: \(viewModel.statusText)")
      .font(.subheadline)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
  }

  // MARK: - Building blocks

  private func card<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func labeledField(
    title: String,
    placeholder: String,
    text: Binding<String>
  ) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)
      TextField(placeholder, text: text)
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
    }
  }

  /// Outlined variant of `actionButton`.
  private func secondaryButton(
    title: String,
    enabled: Bool,
    action: @escaping () async -> Void
  ) -> some View {
    Button {
      hideKeyboard()
      Task { await action() }
    } label: {
      Text(title)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor))
    }
    .disabled(!enabled)
    .opacity(enabled ? 1 : 0.6)
  }

  private func actionButton(
    title: String,
    enabled: Bool,
    isLoading: Bool,
    action: @escaping () async -> Void
  ) -> some View {
    Button {
      hideKeyboard()
      Task { await action() }
    } label: {
      HStack {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
        Text(title)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background(enabled ? Color.accentColor : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(10)
    }
    .disabled(!enabled)
    .opacity(enabled ? 1 : 0.6)
  }
}

#Preview {
  HomeView()
}
