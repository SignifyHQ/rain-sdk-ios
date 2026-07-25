import SwiftUI

/// Withdraws collateral from the Rain contract for the active chain.
struct CollateralWithdrawView: View {
  @StateObject private var viewModel = CollateralWithdrawViewModel()
  @StateObject private var recoverViewModel = RecoverViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared
  @State private var hasShownRecoverOnAppear = false

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
          actionButtons

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
    .onAppear {
      if viewModel.hasPortal && !hasShownRecoverOnAppear {
        hasShownRecoverOnAppear = true
        recoverViewModel.showRecoverSheet()
      }
    }
    .overlay {
      if recoverViewModel.showRecoverChoiceSheet {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture { recoverViewModel.dismissRecoverSheet() }
        RecoverChoiceView(viewModel: recoverViewModel)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: recoverViewModel.showRecoverChoiceSheet)
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

  // Gas estimation happens in the background as part of the withdraw, so there's no separate
  // "Estimate Gas" step. "Withdraw Maximum" withdraws the full available balance.
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
