import Foundation
import RainSDK
import Combine

/// ViewModel for SDK Connection View
/// Handles business logic and state management for SDK initialization
@MainActor
class SDKConnectionViewModel: ObservableObject {
  // MARK: - Dependencies
  
  private let sdkService: RainSDKService
  
  // MARK: - Published Properties
  
  /// Portal session token input
  @Published var portalToken: String = ""
  
  /// RPC URL input
  @Published var rpcUrl: String = "https://avalanche-fuji-c-chain-rpc.publicnode.com"
  
  /// Chain ID input
  @Published var chainId: String = "43113"
  
  /// Initialization mode: true for wallet-agnostic, false for Portal
  @Published var useWalletAgnostic: Bool = false
  
  /// Initialization loading state
  @Published var isInitializing: Bool = false
  
  /// SDK initialization state (from service)
  @Published var isInitialized: Bool = false
  
  /// Current error state (from service)
  @Published var error: RainSDKError?
  
  /// Status message (from service)
  @Published var statusMessage: String = "Not initialized"
  
  // MARK: - Computed Properties
  
  /// Check if initialize button should be enabled
  var canInitialize: Bool {
    !isInitializing
      && !rpcUrl.isEmpty
      && !chainId.isEmpty
      && Int(chainId) != nil
      && (useWalletAgnostic || !portalToken.isEmpty)
  }
  
  // MARK: - Initialization
  
  init(sdkService: RainSDKService = .shared) {
    self.sdkService = sdkService
    self.portalToken = PortalTokenStorage.getToken() ?? ""

    // Observe service state changes
    observeServiceState()
  }
  
  // MARK: - Service State Observation
  
  private func observeServiceState() {
    // Observe isInitialized
    sdkService.$isInitialized
      .assign(to: &$isInitialized)
    
    // Observe error
    sdkService.$error
      .assign(to: &$error)
    
    // Observe statusMessage
    sdkService.$statusMessage
      .assign(to: &$statusMessage)
  }
  
  // MARK: - Actions
  
  /// Initialize the SDK with current input values
  func initializeSDK() async {
    guard let chainIdInt = Int(chainId) else {
      return
    }
    
    isInitializing = true
    
    let networkConfigs = [
      NetworkConfig(
        chainId: chainIdInt,
        rpcUrl: rpcUrl,
        networkName: "Demo Network"
      )
    ]
    
    if useWalletAgnostic {
      await sdkService.initializeWalletAgnostic(networkConfigs: networkConfigs)
    } else {
      PortalTokenStorage.saveToken(portalToken)
      await sdkService.initialize(
        portalToken: portalToken,
        networkConfigs: networkConfigs
      )
    }

    isInitializing = false
  }
  
  /// Reset the SDK state
  func resetSDK() {
    sdkService.reset()
  }
  
  // MARK: - Future Feature Actions
  
  /// Handle Portal wallet features action
  /// TODO: Implement Portal wallet features
  func handlePortalWalletFeatures() {
    // Future implementation
  }
  
  /// Handle collateral withdrawal action
  /// TODO: Implement collateral withdrawal
  func handleCollateralWithdrawal() {
    // Future implementation
  }
  
  /// Handle fee estimation action
  /// TODO: Implement fee estimation
  func handleFeeEstimation() {
    // Future implementation
  }
}
