import SwiftUI

/// Two cards: the Rain collateral wallet (balances from the API) and the internal wallet
/// (balances read on-chain).
struct BalancesView: View {
  @StateObject private var viewModel = BalancesViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared

  private var chain: WalletChain { sdkService.selectedChain }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        collateralCard
        internalWalletCard
      }
      .padding()
    }
    .navigationTitle("Balances")
    .navigationBarTitleDisplayMode(.inline)
    .task(id: chain) { await viewModel.loadWalletAddress(chain: chain) }
  }

  // MARK: - Collateral wallet

  private var collateralCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      walletHeader(
        icon: "info.circle.fill",
        tint: .accentColor,
        title: "Collateral wallet",
        address: viewModel.collateralWalletAddress,
        badge: "Collateral"
      )

      willFetchBox(tint: .secondary) {
        bullet(color: .accentColor, text: "All token balances in this wallet")
      }

      fetchButton(isLoading: viewModel.isCollateralLoading) {
        await viewModel.fetchCollateralBalances(chain: chain)
      }

      if let error = viewModel.collateralError {
        errorText(error)
      }

      if !viewModel.collateralBalances.isEmpty {
        Text("Results:")
          .fontWeight(.bold)
        ForEach(viewModel.collateralBalances) { token in
          balanceRow(
            emoji: "🪙",
            label: token.symbol,
            value: token.balance.formatted(places: 2),
            subtitle: token.displayAddress
          )
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  // MARK: - Internal wallet

  private var internalWalletCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      walletHeader(
        icon: "star",
        tint: .blue,
        title: "Internal wallet",
        address: viewModel.internalWalletAddress,
        badge: "Internal"
      )

      // Token discovery works on every chain: ERC-20s on EVM, SPL tokens on Solana.
      willFetchBox(tint: .blue) {
        bullet(color: .red, text: "\(chain.nativeSymbol) — native token")
        bullet(
          color: .blue,
          text: "Every \(chain.tokenStandard) token with a balance > 0 (auto-discovered)"
        )
      }

      fetchButton(isLoading: viewModel.isLoading) {
        await viewModel.fetchBalances(chain: chain)
      }

      if let error = viewModel.errorMessage {
        errorText(error)
      }

      if viewModel.nativeBalance != nil || !viewModel.walletTokenBalances.isEmpty {
        Text("Results:")
          .fontWeight(.bold)

        if let native = viewModel.nativeBalance {
          balanceRow(emoji: "⛰️", label: "Native (\(chain.nativeSymbol))", value: native)
        }

        if viewModel.walletTokenBalances.isEmpty {
          Text("No \(chain.tokenStandard) tokens with a balance > 0.")
            .font(.subheadline)
            .foregroundColor(.secondary)
        } else {
          Text("Tokens with a balance:")
            .font(.subheadline)
            .fontWeight(.semibold)
          ForEach(viewModel.walletTokenBalances) { token in
            balanceRow(
              emoji: "🪙",
              label: token.displayName,
              // The unit is always stated: an SPL mint has no on-chain symbol, so an
              // unregistered token is named by its mint rather than showing a bare number.
              value: "\(token.formattedBalance) \(token.displayUnit)",
              subtitle: "\(chain.tokenAddressLabel): \(token.address)"
            )
          }
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  // MARK: - Building blocks

  private func walletHeader(
    icon: String,
    tint: Color,
    title: String,
    address: String,
    badge: String
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(tint)
        .frame(width: 40, height: 40)
        .background(tint.opacity(0.12))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .fontWeight(.bold)
        Text(address.isEmpty ? "—" : formatAddress(address))
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()

      Text(badge)
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
    }
  }

  private func willFetchBox<Content: View>(
    tint: Color,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Will fetch")
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(tint)
      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(tint.opacity(0.08))
    .cornerRadius(12)
  }

  private func bullet(color: Color, text: String) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Circle()
        .fill(color)
        .frame(width: 6, height: 6)
        .padding(.top, 6)
      Text(text)
        .font(.subheadline)
        .fontWeight(.medium)
    }
  }

  private func fetchButton(isLoading: Bool, action: @escaping () async -> Void) -> some View {
    Button {
      Task { await action() }
    } label: {
      HStack {
        if isLoading {
          ProgressView()
        } else {
          Text("Fetch").fontWeight(.bold)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary))
    }
    .disabled(isLoading)
    .foregroundColor(.primary)
  }

  private func balanceRow(
    emoji: String,
    label: String,
    value: String,
    subtitle: String? = nil
  ) -> some View {
    HStack(spacing: 12) {
      Text(emoji)
        .font(.title)
      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.subheadline)
          .fontWeight(.medium)
        if let subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      Spacer()
      Text(value)
        .fontWeight(.bold)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
  }

  private func errorText(_ message: String) -> some View {
    Text("Error: \(message)")
      .font(.caption)
      .foregroundColor(.red)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  NavigationStack {
    BalancesView()
  }
}
