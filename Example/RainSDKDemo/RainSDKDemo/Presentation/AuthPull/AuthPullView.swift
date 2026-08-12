import SwiftUI

/// Approves Rain's operator to spend USDC from this wallet — the wallet-side prerequisite for
/// Auth Pull — and shows the resulting allowance.
struct AuthPullView: View {
  @StateObject private var viewModel = AuthPullViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared

  /// Which action the confirmation dialog is standing in front of. An approval is irreversible
  /// once mined and, in production, spends real gas to grant a real spend allowance.
  private enum PendingAction: Identifiable {
    case approve
    case revoke

    var id: Self { self }
  }

  @State private var pendingAction: PendingAction?

  private var chain: WalletChain { sdkService.selectedChain }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        environmentBanner

        if viewModel.supportsAuthPull(chain) {
          allowanceCard
          formCard

          if let error = viewModel.errorText {
            errorCard(error)
          }

          approveButton
          secondaryActions

          if let txHash = viewModel.txHash {
            resultCard(txHash: txHash)
          }

          explainer
        } else {
          unsupportedCard
        }
      }
      .padding()
    }
    .navigationTitle("Auth Pull")
    .navigationBarTitleDisplayMode(.inline)
    // Operator and token are per-environment, so re-seed on a chain switch.
    .task(id: chain) { viewModel.onChainChanged(chain) }
    .onChange(of: viewModel.amount) { viewModel.onAmountChanged() }
    .onChange(of: viewModel.isUnlimited) { viewModel.onUnlimitedChanged() }
    .confirmationDialog(
      pendingAction == .revoke ? "Confirm revocation" : "Confirm Auth Pull approval",
      isPresented: Binding(
        get: { pendingAction != nil },
        set: { if !$0 { pendingAction = nil } }
      ),
      titleVisibility: .visible,
      presenting: pendingAction
    ) { action in
      Button(action == .revoke ? "Revoke" : "Approve", role: action == .revoke ? .destructive : nil) {
        pendingAction = nil
        if action == .revoke {
          viewModel.revoke(chain: chain)
        } else {
          viewModel.approve(chain: chain)
        }
      }
      Button("Cancel", role: .cancel) { pendingAction = nil }
    } message: { action in
      Text(confirmationMessage(for: action))
    }
  }

  /// Spells out exactly what is about to be granted, since the operator and token are no longer
  /// visible as editable fields and "unlimited" is easy to skim past.
  private func confirmationMessage(for action: PendingAction) -> String {
    let allowance: String
    switch action {
    case .revoke:
      allowance = "zero (revoke)"
    case .approve:
      allowance = viewModel.isUnlimited
        ? "UNLIMITED: all current and future USDC until revoked"
        : "\(viewModel.amount) USDC"
    }
    return """
      Environment: \(SampleEnvironment.displayName)
      Chain: \(chain.displayName) (\(chain.chainId))
      Token: \(viewModel.tokenAddress)
      Operator: \(viewModel.operatorAddress)
      Allowance: \(allowance)
      """
  }

  private var environmentBanner: some View {
    Text(
      SampleEnvironment.isProduction
        ? "Production: this approval uses real USDC and real gas."
        : "Sandbox: approvals use testnet USDC and testnet gas."
    )
    .font(.caption)
    .fontWeight(.bold)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background((SampleEnvironment.isProduction ? Color.red : Color.accentColor).opacity(0.12))
    .foregroundColor(SampleEnvironment.isProduction ? .red : .accentColor)
    .cornerRadius(12)
  }

  // MARK: - Allowance

  /// Reads the allowance state rather than describing it as a standing permission, so a revoked
  /// wallet does not read as one Rain can still pull from.
  private var allowanceCaption: String {
    guard viewModel.allowanceText != nil else {
      return "What Rain's operator may pull from this wallet."
    }
    if viewModel.isRevokedAllowance {
      return "Revoked. Rain's operator cannot pull from this wallet."
    }
    if viewModel.isUnlimitedAllowance {
      return "Rain's operator may pull any amount from this wallet."
    }
    return "What Rain's operator may still pull from this wallet."
  }

  private var allowanceCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Current Allowance")
          .font(.subheadline)
          .fontWeight(.bold)
        Spacer()
        Button {
          hideKeyboard()
          viewModel.refreshAllowance(chain: chain)
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoadingAllowance || viewModel.isApproving)
      }

      if viewModel.isLoadingAllowance {
        ProgressView()
      } else if let allowance = viewModel.allowanceText {
        Text(viewModel.isUnlimitedAllowance ? allowance : "\(allowance) USDC")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(viewModel.isUnlimitedAllowance ? .accentColor : .primary)
      } else {
        Text("—")
          .font(.title3)
          .foregroundColor(.secondary)
      }

      Text(allowanceCaption)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Form

  private var formCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Approve Rain Operator")
        .font(.subheadline)
        .fontWeight(.bold)

      // Read-only: the SDK accepts only its configured operator and token, so anything typed here
      // could only ever produce a rejected approval.
      readOnlyAddress(title: "USDC contract", value: viewModel.tokenAddress)
      readOnlyAddress(title: "Trusted Rain operator", value: viewModel.operatorAddress)

      Toggle("Unlimited approval", isOn: $viewModel.isUnlimited)
        .font(.subheadline)
        .disabled(viewModel.isApproving)

      if !viewModel.isUnlimited {
        field(title: "Amount (USDC)", placeholder: "250", text: $viewModel.amount)
          .disabled(viewModel.isApproving)
        Text("Zero revokes the approval.")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      if let fee = viewModel.estimatedFee {
        Text("Estimated network fee: \(fee)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Actions

  private var approveButton: some View {
    Button {
      hideKeyboard()
      pendingAction = .approve
    } label: {
      HStack {
        if viewModel.isApproving {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
        Text(viewModel.isApproving ? "Approving..." : "🔐 Approve Operator")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.isApproving ? Color.gray : Color.accentColor)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(viewModel.isApproving)
  }

  private var secondaryActions: some View {
    HStack(spacing: 12) {
      Button {
        hideKeyboard()
        viewModel.estimateFee(chain: chain)
      } label: {
        Text("Estimate Fee")
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(Color.accentColor.opacity(0.12))
          .cornerRadius(10)
      }

      Button {
        hideKeyboard()
        pendingAction = .revoke
      } label: {
        Text("Revoke")
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(Color.red.opacity(0.12))
          .foregroundColor(.red)
          .cornerRadius(10)
      }
    }
    .disabled(viewModel.isApproving)
  }

  // MARK: - Result / status

  private func resultCard(txHash: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(viewModel.approvalStatus ?? "Approval submitted")
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.accentColor)
      Text(
        viewModel.isApproving
          ? "Waiting for a successful receipt and the exact on-chain allowance."
          : "The receipt and resulting allowance were verified on-chain."
      )
      .font(.caption)
      .foregroundColor(.secondary)
      if let url = chain.explorerTxURL(hash: txHash) {
        Link(destination: url) {
          Text(txHash)
            .font(.system(.caption, design: .monospaced))
            .underline()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      } else {
        Text(txHash)
          .font(.system(.caption, design: .monospaced))
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color.accentColor.opacity(0.1))
    .cornerRadius(12)
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor))
  }

  private func errorCard(_ message: String) -> some View {
    Text(message)
      .font(.subheadline)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(Color.red.opacity(0.12))
      .foregroundColor(.red)
      .cornerRadius(12)
  }

  private var unsupportedCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Auth Pull is not available on \(chain.displayName)")
        .font(.subheadline)
        .fontWeight(.bold)
      Text(
        SampleEnvironment.isProduction
          ? "Production Auth Pull runs on Base and Arbitrum. Switch chains on the home screen."
          : "Sandbox Auth Pull runs on Base Sepolia and Arbitrum Sepolia. Switch chains on the home screen."
      )
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private var explainer: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("How Auth Pull works")
        .font(.caption)
        .fontWeight(.bold)
      Text("""
        Fund this wallet with \(SampleEnvironment.isProduction ? "USDC" : "testnet USDC") and a little \(chain.nativeSymbol) for gas, then approve \
        the operator. When a card authorization arrives, Rain pulls the full amount into the user's \
        collateral contract — the app does nothing further.
        """)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func readOnlyAddress(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption2)
        .foregroundColor(.secondary)
      Text(value)
        .font(.system(.caption, design: .monospaced))
        .textSelection(.enabled)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func field(title: String, placeholder: String, text: Binding<String>) -> some View {
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
}

#Preview {
  NavigationStack {
    AuthPullView()
  }
}
