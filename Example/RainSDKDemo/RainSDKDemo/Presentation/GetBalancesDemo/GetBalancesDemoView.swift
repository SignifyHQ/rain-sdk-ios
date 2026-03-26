import SwiftUI
import RainSDK

struct GetBalancesDemoView: View {
  @StateObject private var viewModel = GetBalancesDemoViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        chainIdSection
        nativeBalanceSection
        erc20BalanceSection
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

  // MARK: - Shared Chain ID

  private var chainIdSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Chain ID")
        .font(.subheadline)
        .foregroundColor(.secondary)

      TextField("e.g. 43113 (Avalanche Fuji), 1 (Ethereum)", text: $viewModel.chainId)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.numberPad)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Native Balance

  private var nativeBalanceSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("Native Token", systemImage: "bitcoinsign.circle")
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

  // MARK: - ERC-20 Balance

  private var erc20BalanceSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("ERC-20 Token", systemImage: "puzzlepiece.extension")
        .font(.headline)

      VStack(alignment: .leading, spacing: 8) {
        Text("Token Contract Address")
          .font(.subheadline)
          .foregroundColor(.secondary)

        TextField("0x…", text: $viewModel.tokenAddress)
          .textFieldStyle(.roundedBorder)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Decimals")
          .font(.subheadline)
          .foregroundColor(.secondary)

        TextField("e.g. 18 (ETH), 6 (USDC)", text: $viewModel.tokenDecimals)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }

      FetchButton(
        title: "Get ERC-20 Balance",
        isLoading: viewModel.isLoadingERC20,
        isDisabled: !viewModel.canFetchERC20
      ) {
        Task { await viewModel.fetchERC20Balance() }
      }

      if let balance = viewModel.erc20Balance {
        VStack(spacing: 4) {
          if let address = viewModel.erc20WalletAddress {
            WalletAddressRow(address: address)
          }
          BalanceHighlight(value: formatBalance(balance))
        }
      }

      if let error = viewModel.erc20Error {
        ErrorBanner(error: error)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Helpers

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
