import Foundation
import RainSDK

enum TransferType: String, CaseIterable {
  case native = "Native (e.g. ETH, AVAX)"
  case erc20 = "ERC-20"
}

@MainActor
class TransferDemoViewModel: ObservableObject {
  @Published var transferType: TransferType = .native
  @Published var chainId: String = "43113"
  @Published var toAddress: String = "0x0C9049B5cCB1C893fc8a5c1CDa8B5cc64c3aA909"
  @Published var amount: String = ""
  @Published var contractAddress: String = ""
  @Published var decimals: String = "18"

  @Published var isProcessing: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var txHash: String?

  @Published var nativeBalance: Double?
  @Published var isLoadingNativeBalance: Bool = false
  @Published var erc20Balance: Double?
  @Published var isLoadingERC20Balance: Bool = false

  private let sdkService = RainSDKService.shared

  init(initialContract: RainCollateralContractResponse? = nil) {
    if let contract = initialContract {
      if let chain = contract.chainId {
        chainId = "\(chain)"
      }
    }
  }

  var canSend: Bool {
    guard sdkService.isInitialized,
          !chainId.isEmpty,
          Int(chainId) != nil,
          !toAddress.trimmingCharacters(in: .whitespaces).isEmpty,
          !amount.isEmpty,
          Double(amount) != nil,
          (Double(amount) ?? 0) > 0
    else { return false }

    if transferType == .erc20 {
      return !contractAddress.trimmingCharacters(in: .whitespaces).isEmpty
        && !decimals.isEmpty
        && Int(decimals) != nil
    }
    
    return true
  }

  func send() async {
    guard let chainIdInt = Int(chainId),
          let amountDouble = Double(amount),
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
      switch transferType {
      case .native:
        let hash = try await sdkService.sendNativeToken(
          chainId: chainIdInt,
          to: to,
          amount: amountDouble
        )
        txHash = hash
      case .erc20:
        guard let decimalsInt = Int(decimals) else {
          statusMessage = "Invalid decimals"
          return
        }
        let contract = contractAddress.trimmingCharacters(in: .whitespaces)
        let hash = try await sdkService.sendERC20Token(
          chainId: chainIdInt,
          contractAddress: contract,
          to: to,
          amount: amountDouble,
          decimals: decimalsInt
        )
        txHash = hash
      }
      statusMessage = "Sent successfully"
      error = nil
    } catch {
      self.error = error
      statusMessage = "Transfer failed"
    }
  }

  func fetchNativeBalance() async {
    guard let chainIdInt = Int(chainId), sdkService.isInitialized else { return }
    isLoadingNativeBalance = true
    defer { isLoadingNativeBalance = false }
    nativeBalance = try? await sdkService.getNativeBalance(chainId: chainIdInt)
  }

  func fetchERC20Balance() async {
    guard let chainIdInt = Int(chainId),
          !contractAddress.trimmingCharacters(in: .whitespaces).isEmpty,
          sdkService.isInitialized else { return }
    isLoadingERC20Balance = true
    defer { isLoadingERC20Balance = false }
    erc20Balance = try? await sdkService.getERC20Balance(
      chainId: chainIdInt,
      tokenAddress: contractAddress.trimmingCharacters(in: .whitespaces),
      decimals: Int(decimals)
    )
  }

  func clearResult() {
    txHash = nil
    error = nil
    statusMessage = "Ready"
  }
}
