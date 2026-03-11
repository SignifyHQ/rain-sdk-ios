import SwiftUI
import UIKit
import RainSDK

struct WalletAddressDemoView: View {
  @StateObject private var viewModel = WalletAddressDemoViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        statusSection
        getAddressSection
        if viewModel.walletAddress != nil {
          addressResultSection
        }
        generateQRSection
        if viewModel.qrImageData != nil {
          qrResultSection
        }
      }
      .padding()
    }
    .navigationTitle("Wallet Address & QR")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          dismiss()
        }
      }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "wallet.pass.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Wallet Address & QR")
        .font(.title2)
        .fontWeight(.bold)

      Text("Get the current wallet address and generate a QR code")
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
            viewModel.isLoadingAddress || viewModel.isLoadingQR
              ? Color.orange
              : (viewModel.walletAddress != nil || viewModel.qrImageData != nil ? Color.green : Color.gray)
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

  // MARK: - Get Address

  private var getAddressSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Wallet Address")
        .font(.headline)

      Button(action: {
        Task { await viewModel.fetchWalletAddress() }
      }) {
        HStack {
          if viewModel.isLoadingAddress {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Image(systemName: "location.circle.fill")
          }
          Text("Get Wallet Address")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.canFetch ? Color.blue : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(!viewModel.canFetch || viewModel.isLoadingAddress)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Address Result

  private var addressResultSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Address")
        .font(.headline)

      if let address = viewModel.walletAddress {
        HStack(alignment: .top) {
          Text(address)
            .font(.system(.caption, design: .monospaced))
            .lineLimit(2)
            .truncationMode(.middle)
          Spacer(minLength: 8)
          Button(action: { viewModel.copyAddress() }) {
            Image(systemName: viewModel.showCopyFeedback ? "checkmark.circle.fill" : "doc.on.doc")
              .foregroundColor(.blue)
          }
          .disabled(viewModel.showCopyFeedback)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Generate QR

  private var generateQRSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("QR Code")
        .font(.headline)

      Button(action: {
        Task { await viewModel.generateQR() }
      }) {
        HStack {
          if viewModel.isLoadingQR {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Image(systemName: "qrcode")
          }
          Text("Generate QR Code")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.canFetch ? Color.blue : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(!viewModel.canFetch || viewModel.isLoadingQR)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - QR Result

  private var qrResultSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("QR Code")
        .font(.headline)

      if let data = viewModel.qrImageData, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: 256, maxHeight: 256)
          .cornerRadius(8)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}

#Preview {
  NavigationStack {
    WalletAddressDemoView()
  }
}
