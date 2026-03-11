import Foundation
import UIKit
import Combine

@MainActor
class WalletAddressDemoViewModel: ObservableObject {
  @Published var walletAddress: String?
  @Published var qrImageData: Data?
  @Published var isLoadingAddress: Bool = false
  @Published var isLoadingQR: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var showCopyFeedback: Bool = false

  private let sdkService = RainSDKService.shared

  var canFetch: Bool {
    sdkService.isInitialized
  }

  func fetchWalletAddress() async {
    guard canFetch else { return }
    isLoadingAddress = true
    statusMessage = "Fetching wallet address..."
    error = nil
    walletAddress = nil

    do {
      let address = try await sdkService.getWalletAddress()
      walletAddress = address
      statusMessage = "Address loaded"
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to get address"
    }
    isLoadingAddress = false
  }

  func generateQR() async {
    guard canFetch else { return }
    if walletAddress == nil {
      await fetchWalletAddress()
    }
    guard walletAddress != nil else { return }

    isLoadingQR = true
    error = nil
    qrImageData = nil

    do {
      let data = try await sdkService.generateWalletAddressQRCode(
        dimension: 256,
        backgroundColor: nil,
        foregroundColor: nil
      )
      qrImageData = data
      statusMessage = "QR code generated"
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to generate QR"
    }
    isLoadingQR = false
  }

  func copyAddress() {
    guard let address = walletAddress else { return }
    UIPasteboard.general.string = address
    showCopyFeedback = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      self?.showCopyFeedback = false
    }
  }
}
