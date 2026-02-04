import Foundation
import Web3
import Combine

@MainActor
class BuildEIP712MessageDemoViewModel: ObservableObject {
  @Published var chainId: String = "43113"
  @Published var collateralProxyAddress: String = "0x5a022623280AA5E922A4D9BB3024fA7D70D7e789"
  @Published var walletAddress: String = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
  @Published var tokenAddress: String = "0x9876543210987654321098765432109876543210"
  @Published var amount: String = "100.0"
  @Published var decimals: String = "18"
  @Published var recipientAddress: String = "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc"
  @Published var nonce: String = ""
  
  @Published var isProcessing: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var result: (message: String, salt: String)?
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
  
  var canBuild: Bool {
    !chainId.isEmpty
    && !collateralProxyAddress.isEmpty
    && !walletAddress.isEmpty
    && !tokenAddress.isEmpty
    && !amount.isEmpty
    && !decimals.isEmpty
    && !recipientAddress.isEmpty
    && Int(chainId) != nil
    && Double(amount) != nil
    && Int(decimals) != nil
    && sdkService.isInitialized
  }
  
  func buildMessage() async {
    guard let chainIdInt = Int(chainId),
          let amountDouble = Double(amount),
          let decimalsInt = Int(decimals) else {
      return
    }
    
    isProcessing = true
    statusMessage = "Building EIP-712 message..."
    error = nil
    result = nil
    
    do {
      let nonceValue: BigUInt? = nonce.isEmpty ? nil : BigUInt(nonce)
      
      let (message, salt) = try await sdkService.buildEIP712Message(
        chainId: chainIdInt,
        collateralProxyAddress: collateralProxyAddress,
        walletAddress: walletAddress,
        tokenAddress: tokenAddress,
        amount: amountDouble,
        decimals: decimalsInt,
        recipientAddress: recipientAddress,
        nonce: nonceValue
      )
      
      result = (message, salt)
      statusMessage = "Success! Message built."
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to build message"
    }
    
    isProcessing = false
  }
}
