import SwiftUI
import RainCore

/// Transaction history for the active chain, each row labelled SEND / RECEIVE / SELF.
struct TransactionHistoryView: View {
  @StateObject private var viewModel = TransactionHistoryViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared
  @State private var copiedTokenAddress: String?

  private var chain: WalletChain { sdkService.selectedChain }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        Button {
          Task { await viewModel.fetchTransactions(chain: chain) }
        } label: {
          Text(viewModel.isLoading ? "Loading..." : "🔄 Refresh (\(chain.nativeSymbol))")
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isLoading ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)

        if let error = viewModel.errorText {
          Text("Error: \(error)")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red.opacity(0.12))
            .foregroundColor(.red)
            .cornerRadius(12)
        }

        // An empty list is expected for a fresh wallet, not a failure: history lists sends from
        // this wallet on the selected network (plus receives where the provider's source has them).
        if !viewModel.isLoading && viewModel.transactions.isEmpty && viewModel.errorText == nil {
          VStack(spacing: 8) {
            Text("No transactions found on \(chain.displayName).")
              .multilineTextAlignment(.center)
            Text("History lists transactions sent from this wallet on the selected network. "
              + "Sends on other chains, or transfers received from someone else, won't appear here.")
              .font(.caption)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
        }

        // Indexed on purpose: a provider row can carry a blank `uniqueId`, and duplicate ids
        // break `ForEach` identity.
        ForEach(Array(viewModel.transactions.enumerated()), id: \.offset) { _, tx in
          transactionCard(tx)
        }
      }
      .padding()
    }
    .navigationTitle("Transaction History")
    .navigationBarTitleDisplayMode(.inline)
    // Re-fetch whenever the active chain changes.
    .task(id: chain) { await viewModel.fetchTransactions(chain: chain) }
  }

  private func transactionCard(_ tx: WalletTransaction) -> some View {
    // Solana history rows carry the Turnkey status id, not an explorer-resolvable signature, so
    // the hash is shown plainly (no link) on Solana.
    let explorerLinkable = !chain.isSolana
    let explorerURL = chain.explorerTxURL(hash: tx.hash)

    return VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 6) {
        Text("Tx Hash")
          .font(.caption)
          .foregroundColor(.secondary)
        if let badge = directionBadge(tx) {
          Text(badge.label)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badge.color)
            .cornerRadius(4)
        }
      }

      if explorerLinkable, let explorerURL {
        Link(destination: explorerURL) {
          Text(truncateHash(tx.hash))
            .font(.caption)
            .fontWeight(.medium)
            .underline()
        }
      } else {
        Text(truncateHash(tx.hash))
          .font(.caption)
          .fontWeight(.medium)
      }

      HStack(alignment: .top, spacing: 8) {
        VStack(alignment: .leading, spacing: 2) {
          Text("From")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(truncateAddress(tx.from))
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Text("→")

        VStack(alignment: .leading, spacing: 2) {
          Text("To")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(truncateAddress(tx.to ?? "—"))
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      if let value = tx.value, value != 0 {
        HStack(spacing: 4) {
          // Only a transfer with no token address is denominated in the native symbol. A token
          // transfer whose symbol is unknown (SPL names live in off-chain metadata) shows the bare
          // amount, identified by the token address beside it — labelling it "SOL" would name the
          // wrong asset entirely.
          let tokenAddress = tx.rawContract?.address
          let unit = tx.asset ?? (tokenAddress == nil ? chain.nativeSymbol : nil)
          Text(["Value: \(value.plainString)", unit].compactMap { $0 }.joined(separator: " "))
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)

          if let tokenAddress {
            Text("(\(truncateAddress(tokenAddress)))")
              .font(.caption)
              .foregroundColor(.secondary)
            Button {
              UIPasteboard.general.string = tokenAddress
              copiedTokenAddress = tokenAddress
              Task {
                try? await Task.sleep(for: .seconds(1.5))
                if copiedTokenAddress == tokenAddress { copiedTokenAddress = nil }
              }
            } label: {
              Text(copiedTokenAddress == tokenAddress ? "✅" : "⧉")
                .foregroundColor(.secondary)
            }
          }
        }
      }

      // Explorer link only where the hash is a real on-chain signature.
      if explorerLinkable, let explorerURL {
        Link(destination: explorerURL) {
          Text("🔎 View on \(chain.explorerName)")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor))
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func directionBadge(_ tx: WalletTransaction) -> (label: String, color: Color)? {
    guard let wallet = viewModel.walletAddress else { return nil }
    let isSend = tx.from.caseInsensitiveCompare(wallet) == .orderedSame
    let isReceive = tx.to?.caseInsensitiveCompare(wallet) == .orderedSame
    switch (isSend, isReceive) {
    case (true, true): return ("SELF", .gray)
    case (true, false): return ("SEND", Color(red: 0.898, green: 0.451, blue: 0.451))
    case (false, true): return ("RECEIVE", Color(red: 0.506, green: 0.780, blue: 0.518))
    default: return nil
    }
  }

  private func truncateHash(_ hash: String) -> String {
    hash.count > 20 ? "\(hash.prefix(12))…\(hash.suffix(6))" : hash
  }

  private func truncateAddress(_ address: String) -> String {
    address.count > 14 ? "\(address.prefix(6))…\(address.suffix(6))" : address
  }
}

#Preview {
  NavigationStack {
    TransactionHistoryView()
  }
}
