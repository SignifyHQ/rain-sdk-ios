import Foundation
import Combine
import Web3

@MainActor
class BuildWithdrawTransactionDemoViewModel: ObservableObject {
  @Published var chainId: String = DemoLocalConfig.chainId
  @Published var contractAddress: String = "0x1234567890123456789012345678901234567890"
  @Published var proxyAddress: String = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
  @Published var tokenAddress: String = "0x9876543210987654321098765432109876543210"
  @Published var amount: String = "100.0"
  @Published var decimals: String = "18"
  @Published var recipientAddress: String = "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc"
  @Published var expiresAt: String = "\(Int(Date().addingTimeInterval(86400).timeIntervalSince1970))"
  // Example 32-byte hex strings (64 hex characters)
  @Published var signatureData: String = "0xa1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890"
  @Published var adminSalt: String = "0x1a2b3c4d5e6f789012345678901234567890abcdef1234567890abcdef1234567890"
  @Published var adminSignature: String = "0xf1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef1234567890"
  
  @Published var isProcessing: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var result: String?
  @Published var showCopyFeedback: Bool = false
  
  private let sdkService = RainSDKService.shared
  
  init() {
    // Observe service initialization state
    sdkService.$isInitialized
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }
  
  private var cancellables = Set<AnyCancellable>()
  private var hasPrefilled = false

  /// Prefills the addressing fields from the Rain API contract authenticated on the home screen
  /// (once per screen open). The signature/salt fields are left as manual placeholders — those
  /// are the admin-signature output (use the Collateral Withdraw screen for the live signature).
  func prefillFromRainAPIIfNeeded() async {
    guard !hasPrefilled, let contract = RainAPIContext.shared.contract else { return }
    hasPrefilled = true

    if let chainId = contract.chainId {
      self.chainId = String(chainId)
    }
    if let controller = contract.controllerAddress, !controller.isEmpty {
      self.contractAddress = controller
    }
    if let proxy = contract.address, !proxy.isEmpty {
      self.proxyAddress = proxy
    }

    let resolvedChainId = contract.chainId ?? DemoLocalConfig.chainIdInt
    if let tokenAddr = RainAPIContext.shared.contractTokenAddresses.first {
      self.tokenAddress = tokenAddr
      if let meta = await sdkService.resolveTokenMetadata(chainId: resolvedChainId, tokenAddress: tokenAddr) {
        self.decimals = String(meta.decimals)
      }
    }

    if let savedRecipient = AppStorage.getCollateralWithdrawRecipientAddress(), !savedRecipient.isEmpty {
      self.recipientAddress = savedRecipient
    }
  }

  var canBuild: Bool {
    !chainId.isEmpty
    && !contractAddress.isEmpty
    && !proxyAddress.isEmpty
    && !tokenAddress.isEmpty
    && !amount.isEmpty
    && !decimals.isEmpty
    && !recipientAddress.isEmpty
    && !expiresAt.isEmpty
    && !signatureData.isEmpty
    && !adminSalt.isEmpty
    && !adminSignature.isEmpty
    && Int(chainId) != nil
    && Double(amount) != nil
    && Int(decimals) != nil
    && sdkService.isInitialized
  }
  
  func buildTransaction() async {
    guard let chainIdInt = Int(chainId),
          let amountDouble = Double(amount),
          let decimalsInt = Int(decimals) else {
      return
    }
    
    // Convert hex strings to Data
    guard let signatureDataBytes = Data(hexString: signatureData),
          let adminSaltBytes = Data(hexString: adminSalt),
          let adminSignatureBytes = Data(hexString: adminSignature) else {
      error = NSError(domain: "Demo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid hex data"])
      return
    }
    
    isProcessing = true
    statusMessage = "Building transaction..."
    error = nil
    result = nil
    
    do {
      let calldata = try await sdkService.buildWithdrawTransactionData(
        chainId: chainIdInt,
        contractAddress: contractAddress,
        proxyAddress: proxyAddress,
        tokenAddress: tokenAddress,
        amount: amountDouble,
        decimals: decimalsInt,
        recipientAddress: recipientAddress,
        expiresAt: expiresAt,
        signatureData: signatureDataBytes,
        adminSalt: adminSaltBytes,
        adminSignature: adminSignatureBytes
      )
      
      result = calldata
      statusMessage = "Success! Transaction calldata generated."
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to build transaction"
    }
    
    isProcessing = false
  }
}
