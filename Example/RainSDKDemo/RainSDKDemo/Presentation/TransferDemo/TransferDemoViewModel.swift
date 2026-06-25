import Foundation
import RainSDK

enum TransferType: String, CaseIterable {
  case native = "Native (e.g. ETH, AVAX)"
  case erc20 = "ERC-20"
}

@MainActor
class TransferDemoViewModel: ObservableObject {
  @Published var transferType: TransferType = .native
  @Published var toAddress: String = ""
  @Published var amount: String = ""
  @Published var contractAddress: String = ""

  @Published var isProcessing: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var txHash: String?

  @Published var nativeBalance: Double?
  @Published var isLoadingNativeBalance: Bool = false
  @Published var erc20Balance: Double?
  @Published var isLoadingERC20Balance: Bool = false

  private let sdkService = RainSDKService.shared

  /// Network selected on the connection screen.
  var chain: WalletChain { sdkService.selectedChain }

  /// ERC-20 mode is structurally impossible on Solana (mirrors the Android sample).
  var isERC20: Bool { !chain.isSolana && transferType == .erc20 }

  var canSend: Bool {
    // Solana transfers are Turnkey-only (Portal's adapter has no Solana support).
    guard sdkService.hasWalletProvider,
          !chain.isSolana || sdkService.activeProvider == .turnkey,
          chain.isValidAddress(toAddress.trimmingCharacters(in: .whitespaces)),
          !amount.isEmpty,
          Double(amount) != nil,
          (Double(amount) ?? 0) > 0
    else { return false }

    if isERC20 {
      return !contractAddress.trimmingCharacters(in: .whitespaces).isEmpty
    }

    return true
  }

  func send() async {
    guard let amountDouble = Double(amount),
          amountDouble > 0,
          canSend
    else { return }

    isProcessing = true
    statusMessage = "Sending..."
    error = nil
    txHash = nil

    defer { isProcessing = false }

    let to = toAddress.trimmingCharacters(in: .whitespaces)

    do {
      if isERC20 {
        // Decimals are resolved by the SDK (registry or on-chain decimals()), so the caller
        // no longer supplies them.
        let contract = contractAddress.trimmingCharacters(in: .whitespaces)
        let result = try await sdkService.sendToken(
          chainId: chain.chainId,
          contractAddress: contract,
          to: to,
          amount: amountDouble
        )
        txHash = result.transactionHash
      } else {
        let result = try await sdkService.sendNativeToken(
          chainId: chain.chainId,
          to: to,
          amount: amountDouble
        )
        txHash = result.transactionHash
      }
      statusMessage = "Sent successfully"
      error = nil
    } catch {
      self.error = error
      statusMessage = "Transfer failed"
    }
  }

  func fetchNativeBalance() async {
    guard sdkService.hasWalletProvider else { return }
    isLoadingNativeBalance = true
    defer { isLoadingNativeBalance = false }
    nativeBalance = try? await sdkService.getNativeBalance(chainId: chain.chainId)
  }

  func fetchERC20Balance() async {
    guard !contractAddress.trimmingCharacters(in: .whitespaces).isEmpty,
          sdkService.hasWalletProvider else { return }
    isLoadingERC20Balance = true
    defer { isLoadingERC20Balance = false }
    erc20Balance = try? await sdkService.getERC20Balance(
      chainId: chain.chainId,
      tokenAddress: contractAddress.trimmingCharacters(in: .whitespaces)
    )
  }

  func clearResult() {
    txHash = nil
    error = nil
    statusMessage = "Ready"
  }
}
