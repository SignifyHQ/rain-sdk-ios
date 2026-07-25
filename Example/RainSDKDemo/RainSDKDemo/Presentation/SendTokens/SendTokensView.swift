import SwiftUI

/// Sends the native token or a fungible token on the active chain.
struct SendTokensView: View {
  @StateObject private var viewModel = SendTokensViewModel()
  @ObservedObject private var sdkService = RainSDKService.shared

  private var chain: WalletChain { sdkService.selectedChain }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Mode toggle — every chain supports both a native and a token transfer.
        Picker("Transfer type", selection: Binding(
          get: { viewModel.isTokenMode },
          set: { viewModel.onSendModeChanged(isToken: $0) }
        )) {
          Text("Native (\(chain.nativeSymbol))").tag(false)
          Text("\(chain.tokenStandard) Token").tag(true)
        }
        .pickerStyle(.segmented)

        formCard

        if let error = viewModel.errorText {
          Text(error)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red.opacity(0.12))
            .foregroundColor(.red)
            .cornerRadius(12)
        }

        sendButton

        if let txHash = viewModel.txHash {
          resultCard(txHash: txHash)
        }
      }
      .padding()
    }
    .navigationTitle("Send Tokens")
    .navigationBarTitleDisplayMode(.inline)
    // Address defaults differ per chain (contract vs mint), so re-seed the form on a switch.
    .task(id: chain) { viewModel.onChainChanged(chain) }
  }

  private var formCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(viewModel.isTokenMode
        ? "Send \(chain.tokenStandard) Token"
        : "Send Native \(chain.nativeSymbol)")
        .font(.subheadline)
        .fontWeight(.bold)

      if viewModel.isTokenMode {
        field(title: chain.tokenAddressLabel, placeholder: chain.isSolana ? "Mint address (Base58)" : "0x…", text: $viewModel.contractAddress)
        Text(chain.isSolana
          ? "Decimals come from the mint. If the recipient has no account for this token, one is created and you pay ~0.002 SOL rent."
          : "Decimals are resolved automatically by the SDK")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      field(title: "Recipient Address", placeholder: chain.isSolana ? "Base58 address" : "0x…", text: $viewModel.recipientAddress)

      field(
        title: viewModel.isTokenMode ? "Amount (Token Units)" : "Amount (\(chain.nativeSymbol))",
        placeholder: "0.001",
        text: $viewModel.amount
      )
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private var sendButton: some View {
    Button {
      hideKeyboard()
      if viewModel.isTokenMode {
        viewModel.sendTokenTransfer(chain: chain)
      } else {
        viewModel.sendNative(chain: chain)
      }
    } label: {
      HStack {
        if viewModel.isSending {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
        Text(sendButtonTitle)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.isSending ? Color.gray : Color.accentColor)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(viewModel.isSending)
  }

  private var sendButtonTitle: String {
    if viewModel.isSending { return "Sending..." }
    return viewModel.isTokenMode
      ? "🔗 Send \(chain.tokenStandard)"
      : "💎 Send \(chain.nativeSymbol)"
  }

  private func resultCard(txHash: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("✅ Transaction Sent")
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.accentColor)
      Text("Tx Hash:")
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
    SendTokensView()
  }
}
