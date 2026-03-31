import SwiftUI
import UIKit
import RainSDK

struct TransferDemoView: View {
  @StateObject private var viewModel: TransferDemoViewModel
  @StateObject private var recoverViewModel = RecoverViewModel()
  @State private var hasShownRecoverOnAppear = false
  @Environment(\.dismiss) private var dismiss
  private let popToRoot: (() -> Void)?

  init(initialContract: RainCollateralContractResponse? = nil, popToRoot: (() -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: TransferDemoViewModel(initialContract: initialContract))
    self.popToRoot = popToRoot
  }

  var body: some View {
    ZStack {
      ScrollView {
        VStack(spacing: 24) {
          headerSection
          statusSection
          inputSection
          actionsSection
          if let hash = viewModel.txHash {
            resultSection(txHash: hash)
          }
        }
        .padding()
      }

      if viewModel.isProcessing {
        loadingOverlay
      }
    }
    .navigationTitle("Transfer")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          if let popToRoot {
            popToRoot()
          } else {
            dismiss()
          }
        }
      }
    }
    .onAppear {
      if RainSDKService.shared.hasPortal, !hasShownRecoverOnAppear {
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

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "arrow.right.arrow.left.circle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Transfer")
        .font(.title2)
        .fontWeight(.bold)

      Text("Send native or ERC-20 tokens from the current wallet")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Status

  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Circle()
          .fill(
            viewModel.isProcessing
              ? Color.orange
              : (viewModel.txHash != nil ? Color.green : Color.gray)
          )
          .frame(width: 12, height: 12)

        Text(viewModel.statusMessage)
          .font(.body)
      }

      if let error = viewModel.error {
        Text("Error: \(error.localizedDescription)")
          .font(.caption)
          .foregroundColor(.red)
          .padding(8)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Input

  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Transfer")
        .font(.headline)

      inputField(title: "Chain ID", text: $viewModel.chainId, placeholder: "e.g. 43113, 1")
        .keyboardType(.numberPad)

      inputField(title: "To Address", text: $viewModel.toAddress, placeholder: "0x...")

      inputField(title: "Amount", text: $viewModel.amount, placeholder: "e.g. 0.01")
        .keyboardType(.decimalPad)

      VStack(alignment: .leading, spacing: 8) {
        Text("Type")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Picker("Type", selection: $viewModel.transferType) {
          ForEach(TransferType.allCases, id: \.self) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(.menu)
      }

      if viewModel.transferType == .native {
        balanceRow(
          balance: viewModel.nativeBalance,
          isLoading: viewModel.isLoadingNativeBalance
        ) {
          Task { await viewModel.fetchNativeBalance() }
        }
      }

      if viewModel.transferType == .erc20 {
        inputField(title: "Token Contract Address", text: $viewModel.contractAddress, placeholder: "0x...")
        inputField(title: "Decimals", text: $viewModel.decimals, placeholder: "e.g. 18, 6")
          .keyboardType(.numberPad)
        balanceRow(
          balance: viewModel.erc20Balance,
          isLoading: viewModel.isLoadingERC20Balance
        ) {
          Task { await viewModel.fetchERC20Balance() }
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func balanceRow(balance: Double?, isLoading: Bool, onReload: @escaping () -> Void) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("Available Balance")
          .font(.caption)
          .foregroundColor(.secondary)
        if isLoading {
          ProgressView()
            .scaleEffect(0.8)
            .frame(height: 20)
        } else {
          Text(balance.map { String(format: "%.6f", $0) } ?? "Tap reload to fetch")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(balance != nil ? .primary : .secondary)
        }
      }
      Spacer()
      Button(action: onReload) {
        HStack(spacing: 4) {
          Image(systemName: "arrow.clockwise")
          Text("Reload")
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(isLoading ? 0.3 : 1))
        .foregroundColor(.white)
        .cornerRadius(8)
      }
      .disabled(isLoading)
    }
    .padding(12)
    .background(Color(.systemBackground))
    .cornerRadius(10)
  }

  private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)

      TextField(placeholder, text: text)
        .textFieldStyle(.roundedBorder)
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
  }

  // MARK: - Actions

  private var actionsSection: some View {
    Button(action: {
      hideKeyboard()
      Task { await viewModel.send() }
    }) {
      HStack {
        if viewModel.isProcessing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "paperplane.fill")
        }
        Text("Send")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canSend ? Color.blue : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canSend || viewModel.isProcessing)
    .opacity(viewModel.canSend ? 1 : 0.6)
  }

  // MARK: - Helpers

  private func snowtraceURL(hash: String, chainId: Int) -> URL? {
    let base: String
    switch chainId {
    case 43114: base = "https://snowtrace.io/tx/"
    case 43113: base = "https://testnet.snowtrace.io/tx/"
    default:    return nil
    }
    return URL(string: base + hash)
  }

  // MARK: - Result

  private func resultSection(txHash: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Transaction Hash")
          .font(.headline)
        Spacer()
        Button {
          UIPasteboard.general.string = txHash
        } label: {
          Image(systemName: "doc.on.doc")
        }
        .font(.caption)
        .foregroundColor(.blue)
        Button("Clear") {
          viewModel.clearResult()
        }
        .font(.caption)
        .foregroundColor(.blue)
      }

      Group {
        if let url = snowtraceURL(hash: txHash, chainId: Int(viewModel.chainId) ?? 0) {
          Link(destination: url) {
            Text(txHash)
              .font(.system(.caption, design: .monospaced))
              .underline()
              .foregroundColor(.blue)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        } else {
          Text(txHash)
            .font(.system(.caption, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(12)
      .background(Color(.systemBackground))
      .cornerRadius(8)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Loading overlay

  private var loadingOverlay: some View {
    Color.black.opacity(0.35)
      .ignoresSafeArea()
      .overlay {
        VStack(spacing: 16) {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.2)
          Text("Sending...")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
        }
        .padding(24)
        .background(Color(.systemGray).opacity(0.9))
        .cornerRadius(12)
      }
  }
}

#Preview {
  NavigationStack {
    TransferDemoView()
  }
}
