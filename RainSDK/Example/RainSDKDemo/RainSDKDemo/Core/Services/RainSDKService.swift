import Foundation
import RainSDK

/// Service class for managing Rain SDK operations
@MainActor
class RainSDKService: ObservableObject {
  // MARK: - Properties
  
  /// The Rain SDK manager instance
  private let sdkManager = RainSDKManager()
  
  /// Current initialization state
  @Published var isInitialized = false
  
  /// Current error state
  @Published var error: RainSDKError?
  
  /// Current initialization status message
  @Published var statusMessage: String = "Not initialized"
  
  // MARK: - Initialization
  
  /// Initialize the SDK with Portal token and network configurations
  /// - Parameters:
  ///   - portalToken: Portal session token
  ///   - networkConfigs: Array of network configurations
  func initialize(portalToken: String, networkConfigs: [NetworkConfig]) async {
    statusMessage = "Initializing..."
    error = nil
    
    do {
      // Enable logging for demo
      RainLogger.isEnabled = true
      
      try await sdkManager.initializePortal(
        portalSessionToken: portalToken,
        networkConfigs: networkConfigs
      )
      
      isInitialized = true
      statusMessage = "Initialized successfully with \(networkConfigs.count) network(s)"
      error = nil
    } catch let sdkError as RainSDKError {
      isInitialized = false
      error = sdkError
      statusMessage = "Initialization failed: \(sdkError.errorCode)"
    } catch {
      isInitialized = false
      self.error = RainSDKError.providerError(underlying: error)
      statusMessage = "Initialization failed: Unknown error"
    }
  }
  
  // MARK: - Portal Access
  
  /// Check if SDK is initialized
  var hasPortal: Bool {
    do {
      _ = try sdkManager.portal
      return true
    } catch {
      return false
    }
  }
  
  // MARK: - Reset
  
  /// Reset the SDK state
  func reset() {
    isInitialized = false
    error = nil
    statusMessage = "Reset"
  }
}
