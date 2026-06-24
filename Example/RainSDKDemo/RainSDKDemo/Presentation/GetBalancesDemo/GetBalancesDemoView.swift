import SwiftUI
import RainSDK

struct GetBalancesDemoView: View {
  @StateObject private var viewModel = GetBalancesDemoViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        networkSection
        nativeBalanceSection
        if !viewModel.chain.isSolana {
          erc20BalanceSection
        }
        allBalancesSection
      }
      .padding()
    }
    .navigationTitle("Get Balances")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") { dismiss() }
      }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "dollarsign.circle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Get Balances")
        .font(.title2)
        .fontWeight(.bold)

      Text("Fetch native and ERC-20 token balances for the current wallet")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Network

  private var networkSection: some View {
    HStack {
      Text("Network")
        .font(.subheadline)
        .foregroundColor(.secondary)
      Spacer()
      Text(viewModel.chain.displayName)
        .font(.subheadline)
        .fontWeight(.medium)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Native Balance

  private var nativeBalanceSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("Native Token (\(viewModel.chain.nativeSymbol))", systemImage: "bitcoinsign.circle")
        .font(.headline)

      FetchButton(
        title: "Get Native Balance",
        isLoading: viewModel.isLoadingNative,
        isDisabled: !viewModel.canFetch
      ) {
        Task { await viewModel.fetchNativeBalance() }
      }

      if let balance = viewModel.nativeBalance {
        VStack(spacing: 4) {
          if let address = viewModel.nativeWalletAddress {
            WalletAddressRow(address: address)
          }
          BalanceHighlight(value: formatBalance(balance))
        }
      }

      if let error = viewModel.nativeError {
        ErrorBanner(error: error)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - ERC-20 Balances (auto-discovered)

  private var erc20BalanceSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("ERC-20 Tokens", systemImage: "puzzlepiece.extension")
        .font(.headline)

      Text("Lists every ERC-20 with a balance > 0 — auto-discovered. No contract address or decimals needed; the SDK resolves each token's name, symbol, and decimals.")
        .font(.caption)
        .foregroundColor(.secondary)

      FetchButton(
        title: "Get ERC-20 Balances",
        isLoading: viewModel.isLoadingTokens,
        isDisabled: !viewModel.canFetchTokens
      ) {
        Task { await viewModel.fetchTokenBalances() }
      }

      if let address = viewModel.tokensWalletAddress {
        WalletAddressRow(address: address)
      }

      if !viewModel.walletTokens.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(viewModel.walletTokens) { token in
            BalanceRow(
              label: token.displayName,
              value: formatBalance(token.balance)
            )
          }
        }
      } else if viewModel.didFetchTokens && viewModel.tokensError == nil {
        Text("No ERC-20 tokens with a balance > 0.")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      if let error = viewModel.tokensError {
        ErrorBanner(error: error)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - All Balances (cross-chain)

  private var allBalancesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("All Chains", systemImage: "globe")
        .font(.headline)

      Text("Fetches balances across every configured chain in parallel. Chains outside Turnkey's allowlist read via Multicall3.")
        .font(.caption)
        .foregroundColor(.secondary)

      FetchButton(
        title: "Get All Balances",
        isLoading: viewModel.isLoadingAll,
        isDisabled: !RainSDKService.shared.isInitialized
      ) {
        Task { await viewModel.fetchAllBalances() }
      }

      if let all = viewModel.allBalances {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(all.keys.sorted(), id: \.self) { chainId in
            let entries = all[chainId] ?? [:]
            VStack(alignment: .leading, spacing: 4) {
              Text(WalletChain.from(chainId: chainId)?.displayName ?? "Chain \(chainId)")
                .font(.subheadline)
                .fontWeight(.semibold)
              if entries.isEmpty {
                Text("No balances (chain failed or unsupported)")
                  .font(.caption)
                  .foregroundColor(.secondary)
              } else {
                ForEach(entries.keys.sorted(), id: \.self) { token in
                  BalanceRow(
                    label: token.isEmpty ? "Native" : shortAddress(token),
                    value: formatBalance(entries[token] ?? 0)
                  )
                }
              }
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
          }
        }
      }

      if let error = viewModel.allError {
        ErrorBanner(error: error)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Helpers

  private func shortAddress(_ address: String) -> String {
    guard address.count > 10 else { return address }
    let prefix = address.prefix(6)
    let suffix = address.suffix(4)
    return "\(prefix)…\(suffix)"
  }

  private func formatBalance(_ value: Double) -> String {
    if value >= 1_000_000 { return String(format: "%.2f", value) }
    if value >= 1         { return String(format: "%.4f", value) }
    if value > 0          { return String(format: "%.6f", value) }
    return "0"
  }
}

// MARK: - Subviews

private struct FetchButton: View {
  let title: String
  let isLoading: Bool
  let isDisabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.clockwise.circle.fill")
        }
        Text(title)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(isDisabled ? Color.gray : Color.blue)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(isDisabled || isLoading)
  }
}

private struct WalletAddressRow: View {
  let address: String
  @State private var copied = false

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Wallet")
        .font(.subheadline)
        .foregroundColor(.secondary)

      HStack(alignment: .top, spacing: 8) {
        Text(address)
          .font(.system(.footnote, design: .monospaced))
          .foregroundColor(.primary)
          .fixedSize(horizontal: false, vertical: true)

        Spacer()

        Button {
          UIPasteboard.general.string = address
          copied = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
        } label: {
          Image(systemName: copied ? "checkmark" : "doc.on.doc")
            .font(.footnote)
            .foregroundColor(copied ? .green : .blue)
        }
        .animation(.easeInOut(duration: 0.2), value: copied)
      }
    }
    .padding(10)
    .background(Color(.systemBackground))
    .cornerRadius(8)
  }
}

private struct BalanceHighlight: View {
  let value: String

  var body: some View {
    HStack {
      Text("Balance")
        .font(.subheadline)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.blue)
    }
    .padding(10)
    .background(Color(.systemBackground))
    .cornerRadius(8)
  }
}

private struct BalanceRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .font(.subheadline)
        .fontWeight(.semibold)
    }
    .padding(10)
    .background(Color(.systemBackground))
    .cornerRadius(8)
  }
}

private struct ErrorBanner: View {
  let error: Error

  var body: some View {
    Text("Error: \(error.localizedDescription)")
      .font(.caption)
      .foregroundColor(.red)
      .padding(8)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.red.opacity(0.1))
      .cornerRadius(8)
  }
}

#Preview {
  NavigationStack {
    GetBalancesDemoView()
  }
}
