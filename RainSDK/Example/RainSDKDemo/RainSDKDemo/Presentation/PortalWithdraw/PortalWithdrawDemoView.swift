import SwiftUI
import UIKit
import RainSDK
import Combine
import Web3

struct PortalWithdrawDemoView: View {
  @StateObject private var viewModel: PortalWithdrawDemoViewModel
  @StateObject private var recoverViewModel: RecoverViewModel
  @State private var hasShownRecoverOnAppear = false

  /// When `initialContract` is provided (e.g. from entry after token verification), assets are derived from it. Otherwise the view model may load contracts itself.
  init(initialContract: RainCollateralContractResponse? = nil) {
    _viewModel = StateObject(wrappedValue: PortalWithdrawDemoViewModel(initialContract: initialContract))
    _recoverViewModel = StateObject(wrappedValue: RecoverViewModel())
  }
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack {
      ScrollView {
        VStack(spacing: 24) {
          headerSection
          statusSection
          inputSection
          actionsSection
          if let txHash = viewModel.txHash {
            resultSection(txHash: txHash)
          }
        }
        .padding()
      }

      if let message = viewModel.loadingMessage {
        loadingOverlay(message: message)
      }
    }
    .navigationTitle("Portal Withdraw")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          dismiss()
        }
      }
    }
    .onAppear {
      if viewModel.hasPortal, !hasShownRecoverOnAppear {
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

  private func loadingOverlay(message: String) -> some View {
    Color.black.opacity(0.35)
      .ignoresSafeArea()
      .overlay {
        VStack(spacing: 16) {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.2)
          Text(message)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
        }
        .padding(24)
        .background(Color(.systemGray).opacity(0.9))
        .cornerRadius(12)
      }
  }

  // MARK: - Header Section

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "wallet.pass.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Portal Withdraw")
        .font(.title2)
        .fontWeight(.bold)

      Text("Execute collateral withdrawal via Portal (build, sign, submit)")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Status Section

  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Circle()
          .fill(viewModel.isProcessing ? Color.orange : (viewModel.txHash != nil ? Color.green : (viewModel.hasPortal ? Color.blue : Color.gray)))
          .frame(width: 12, height: 12)

        Text(viewModel.statusMessage)
          .font(.body)
      }

      if !viewModel.hasPortal {
        Text("Initialize SDK with Portal (not wallet-agnostic) to use this feature.")
          .font(.caption)
          .foregroundColor(.orange)
      }

      if let error = viewModel.error {
        Text("Error: \(error.localizedDescription)")
          .font(.caption)
          .foregroundColor(.red)
          .padding()
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Input Section

  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Withdraw")
        .font(.headline)

      inputField(title: "Recipient Address", text: $viewModel.recipientAddress, placeholder: "0x...")

      inputField(title: "Amount", text: $viewModel.amount, placeholder: "e.g., 100.0")

      assetDropdown
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .opacity(viewModel.hasPortal ? 1 : 0.7)
  }

  private var assetDropdown: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Asset")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Button {
          hideKeyboard()
          Task { await viewModel.loadCreditContracts() }
        } label: {
          Image(systemName: "arrow.clockwise")
            .font(.subheadline)
            .foregroundColor(viewModel.isLoadingAssets ? .secondary : .blue)
        }
        .disabled(viewModel.isLoadingAssets)
      }

      if viewModel.assets.isEmpty && !viewModel.isLoadingAssets {
        Text("No assets available")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(12)
          .background(Color(.systemBackground))
          .cornerRadius(8)
      } else if viewModel.isLoadingAssets {
        HStack {
          ProgressView()
          Text("Loading assets...")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
      } else {
        Menu {
          ForEach(viewModel.assets) { asset in
            Button {
              viewModel.selectedAsset = asset
            } label: {
              HStack {
                Text(assetDropdownLabel(for: asset))
                if viewModel.selectedAsset?.id == asset.id {
                  Image(systemName: "checkmark")
                }
              }
            }
          }
        } label: {
          HStack {
            if let asset = viewModel.selectedAsset {
              Text(assetDropdownLabel(for: asset))
                .foregroundColor(.primary)
            } else {
              Text("Choose asset")
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.down")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(.systemBackground))
          .cornerRadius(8)
        }
      }
    }
  }

  private func assetDropdownLabel(for asset: AssetModel) -> String {
    let symbol = asset.type?.rawValue.uppercased() ?? "Asset"
    let balance = asset.availableBalanceFormatted
    return "\(symbol) (\(balance) available)"
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

  // MARK: - Actions Section

  private var actionsSection: some View {
    Button(action: {
      hideKeyboard()
      Task {
        await viewModel.withdraw()
      }
    }) {
      HStack {
        if viewModel.isProcessing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.down.circle.fill")
        }

        Text("Withdraw via Portal")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canWithdraw ? Color.blue : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canWithdraw || viewModel.isProcessing)
  }

  // MARK: - Result Section

  private func resultSection(txHash: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Transaction Hash")
          .font(.headline)

        Spacer()

        Button(action: {
          UIPasteboard.general.string = txHash
          viewModel.showCopyFeedback = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            viewModel.showCopyFeedback = false
          }
        }) {
          HStack(spacing: 4) {
            Image(systemName: "doc.on.doc")
            Text("Copy")
          }
          .font(.caption)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
      }

      Text(txHash)
        .font(.system(.caption, design: .monospaced))
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .textSelection(.enabled)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .overlay(
      Group {
        if viewModel.showCopyFeedback {
          Text("Copied!")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .transition(.opacity)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      .padding(16)
      .animation(.easeInOut, value: viewModel.showCopyFeedback)
    )
  }
}

#Preview {
  NavigationView {
    PortalWithdrawDemoView()
  }
}
