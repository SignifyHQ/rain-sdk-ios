import SwiftUI

/// Withdraws collateral from the Rain contract for the active chain.
struct CollateralWithdrawView: View {
  @StateObject private var viewModel = CollateralWithdrawViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared

  private var chain: WalletChain { sdkService.selectedChain }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        if viewModel.isLoadingContract {
          Text("Loading contract info...")
            .frame(maxWidth: .infinity)
        }

        if let error = viewModel.errorText {
          Text("Error: \(error)")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red.opacity(0.12))
            .foregroundColor(.red)
            .cornerRadius(12)
        }

        if !viewModel.availableTokens.isEmpty {
          tokenSelection
          field(
            title: "Recipient Address",
            placeholder: "0x…",
            text: Binding(
              get: { viewModel.recipientAddress },
              set: { viewModel.onRecipientChanged($0) }
            )
          )
          amountField
          dryRunButtons
          actionButtons

          // Dry-run results — neither of these broadcast anything.
          if let fee = viewModel.estimatedFee {
            dryRunCard(title: "⛽ Estimated Fee", body: fee)
          }
          if let prepared = viewModel.preparedWithdrawal {
            dryRunCard(
              title: "📝 Prepared (not broadcast)",
              body: prepared,
              footnote: "A Solana blockhash is valid ~60-90s — submit promptly or re-prepare."
            )
          }
          if let txHash = viewModel.withdrawResult {
            resultCard(txHash: txHash)
          }
        }
      }
      .padding()
    }
    .navigationTitle("Collateral Withdraw")
    .navigationBarTitleDisplayMode(.inline)
    // Re-load whenever the active chain changes so the screen shows that chain's contract.
    .task(id: chain) { await viewModel.loadContractInfo(chain: chain) }
  }

  private var tokenSelection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Select Token")
        .font(.subheadline)
        .fontWeight(.bold)

      ForEach(Array(viewModel.availableTokens.enumerated()), id: \.element.id) { index, token in
        Button {
          viewModel.onTokenSelected(index)
        } label: {
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text(token.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
              Text("Balance: \(token.balance.formatted(places: 2))")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            if index == viewModel.selectedTokenIndex {
              Text("✅")
            }
          }
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(index == viewModel.selectedTokenIndex
            ? Color.accentColor.opacity(0.12)
            : Color(.systemBackground))
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(
                index == viewModel.selectedTokenIndex ? Color.accentColor : Color.secondary.opacity(0.3),
                lineWidth: index == viewModel.selectedTokenIndex ? 2 : 1
              )
          )
        }
        .buttonStyle(.plain)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private var amountField: some View {
    VStack(alignment: .leading, spacing: 6) {
      field(
        title: "Amount to Withdraw",
        placeholder: "e.g. 1.5",
        text: Binding(
          get: { viewModel.amount },
          set: { viewModel.onAmountChanged($0) }
        )
      )

      if let token = viewModel.selectedToken {
        if viewModel.isAmountOverBalance {
          Text("Amount exceeds available balance (\(token.balance.formatted(places: 6)) \(token.symbol))")
            .font(.caption)
            .foregroundColor(.red)
        } else {
          Text("Available: \(token.balance.formatted(places: 6)) \(token.symbol)")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
  }

  // Both dry-run actions build the withdrawal exactly as "Withdraw" would — signing EIP-712 and
  // reading the collateral's admin set — but broadcast nothing.
  private var dryRunButtons: some View {
    HStack(spacing: 8) {
      Button {
        hideKeyboard()
        Task { await viewModel.estimateFee() }
      } label: {
        Text("Estimate Fee")
          .frame(maxWidth: .infinity)
          .padding()
          .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor))
      }
      // EVM only: the SDK rejects a Solana chain id for fee estimation.
      .disabled(!viewModel.canDryRun || viewModel.isSolanaContract)
      .opacity(viewModel.canDryRun && !viewModel.isSolanaContract ? 1 : 0.6)

      Button {
        hideKeyboard()
        Task { await viewModel.prepareWithdrawal() }
      } label: {
        Text("Prepare Only")
          .frame(maxWidth: .infinity)
          .padding()
          .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor))
      }
      .disabled(!viewModel.canDryRun)
      .opacity(viewModel.canDryRun ? 1 : 0.6)
    }
  }

  private func dryRunCard(title: String, body: String, footnote: String? = nil) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .fontWeight(.bold)
      Text(body)
        .font(.caption)
        .textSelection(.enabled)
      if let footnote {
        Text(footnote)
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.5)))
  }

  // Gas estimation also happens in the background as part of the withdraw, so "Estimate Fee"
  // above is optional. "Withdraw Maximum" withdraws the full available balance.
  private var actionButtons: some View {
    HStack(spacing: 8) {
      Button {
        hideKeyboard()
        Task { await viewModel.withdrawMaximum() }
      } label: {
        Text("Withdraw Maximum")
          .frame(maxWidth: .infinity)
          .padding()
          .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor))
      }
      .disabled(!viewModel.canWithdrawMaximum)
      .opacity(viewModel.canWithdrawMaximum ? 1 : 0.6)

      Button {
        hideKeyboard()
        Task { await viewModel.executeWithdraw() }
      } label: {
        HStack {
          if viewModel.isWithdrawing {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          }
          Text(viewModel.isWithdrawing ? "Withdrawing..." : "🔓 Withdraw")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.isAmountValid && !viewModel.isWithdrawing ? Color.red : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(!viewModel.isAmountValid || viewModel.isWithdrawing)
    }
  }

  private func resultCard(txHash: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("✅ Withdrawal Successful")
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.accentColor)
      Text("Tx Hash:")
        .font(.caption)
        .foregroundColor(.secondary)

      // Link to the explorer for the contract's actual chain (Base Sepolia → Basescan), not a
      // hardcoded one.
      let contractChain = WalletChain.from(chainId: viewModel.contractChainId) ?? .baseSepolia
      if let url = contractChain.explorerTxURL(hash: txHash) {
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
    CollateralWithdrawView()
  }
}
