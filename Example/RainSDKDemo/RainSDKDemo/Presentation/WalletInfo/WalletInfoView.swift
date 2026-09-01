import SwiftUI

/// Wallet address + collateral deposit address, each with a QR code and a copy button.
struct WalletInfoView: View {
  @StateObject private var viewModel = WalletInfoViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared
  @State private var copiedAddress: String?

  private var chain: WalletChain { sdkService.selectedChain }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        if viewModel.isLoading {
          Text("Loading wallet info...")
            .frame(maxWidth: .infinity)
        }

        if let error = viewModel.errorText {
          errorCard(error)
          Button("Retry") {
            Task { await viewModel.fetchWalletInfo(chain: chain) }
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(Color.accentColor)
          .foregroundColor(.white)
          .cornerRadius(10)
        }

        // User wallet address (provider-agnostic — Portal, Turnkey, or Privy).
        if !viewModel.walletAddress.isEmpty {
          addressCard(
            title: "\(chain.nativeSymbol) Wallet Address",
            address: viewModel.walletAddress,
            qr: viewModel.walletQR
          )
        }

        // Collateral deposit address, from the Rain contract for this chain family.
        if !viewModel.collateralAddress.isEmpty {
          addressCard(
            title: "Deposit Address (Collateral)",
            address: viewModel.collateralAddress,
            qr: viewModel.collateralQR
          )
        }
      }
      .padding()
    }
    .navigationTitle("Wallet & QR")
    .navigationBarTitleDisplayMode(.inline)
    // Re-fetch whenever the active chain changes so the screen shows that wallet's address.
    .task(id: chain) { await viewModel.fetchWalletInfo(chain: chain) }
  }

  private func addressCard(title: String, address: String, qr: UIImage?) -> some View {
    VStack(spacing: 12) {
      HStack {
        Text(title)
          .font(.subheadline)
          .fontWeight(.bold)
        Spacer()
        let isValid = chain.isValidAddress(address)
        Text(isValid ? "✅ Valid" : "❌ Invalid")
          .font(.caption)
          .foregroundColor(isValid ? .green : .red)
      }

      if let qr {
        Image(uiImage: qr)
          .interpolation(.none)
          .resizable()
          .frame(width: 200, height: 200)
          .accessibilityLabel("\(title) QR Code")
      }

      Text(address)
        .font(.caption)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)

      Button {
        UIPasteboard.general.string = address
        copiedAddress = address
        Task {
          try? await Task.sleep(for: .seconds(1.5))
          if copiedAddress == address { copiedAddress = nil }
        }
      } label: {
        Text(copiedAddress == address ? "✅ Copied!" : "📋 Copy Address")
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor))
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func errorCard(_ message: String) -> some View {
    Text("Error: \(message)")
      .font(.subheadline)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(Color.red.opacity(0.12))
      .foregroundColor(.red)
      .cornerRadius(12)
  }
}

#Preview {
  NavigationStack {
    WalletInfoView()
  }
}
