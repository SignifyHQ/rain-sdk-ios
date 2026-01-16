import Foundation
import PortalSwift

// Declaration of Portal wallet instance and the init method
public protocol RainSDK {
  /// The initialized Portal instance
  var portal: Portal { get throws }
  
  /// Initializes the SDK with a Portal token and network configurations
  /// - Parameters:
  ///   - portalSessionToken: A valid Portal session token
  ///   - networkConfigs: Array of network configurations, each containing chain ID and RPC URL
  ///     Example: [NetworkConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/..."),
  ///               NetworkConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")]
  /// - Throws: RainSDKError if initialization fails (e.g., invalid token, invalid RPC URLs)
  func initializePortal(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) async throws
}
