import Foundation
import PortalSwift

public final class RainSDKManager: RainSDK {
  // MARK: - Properties

  // Internal storage for Portal instance
  private var _portal: Portal?
  
  /// Computed property to safely access the Portal instance
  public var portal: Portal {
    get throws {
      guard let portal = _portal
      else {
        throw RainSDKError.sdkNotInitialized
      }
      
      return portal
    }
  }
  
  public func initializePortal(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) async throws {
    // Validate inputs
    try validateInputs(portalSessionToken: portalSessionToken, networkConfigs: networkConfigs)
    
    // Convert network configs to Portal format
    let eip155RpcEndpointsConfig = try buildRpcConfig(from: networkConfigs)
    
    do {
      // Initialize Portal instance
      let portal = try Portal(
        portalSessionToken,
        withRpcConfig: eip155RpcEndpointsConfig,
        autoApprove: true,
        iCloud: ICloudStorage(),
        keychain: PortalKeychain(),
        passwords: PasswordStorage()
      )
      
      // Store portal instance
      _portal = portal
      
      RainLogger.info("Rain SDK: Registered Portal instance successfully with \(networkConfigs.count) network(s)")
    } catch let error as RainSDKError {
      RainLogger.error("Rain SDK: Initialization error - \(error.localizedDescription)")
      throw error
    } catch {
      RainLogger.error("Rain SDK: Portal SDK error - \(error.localizedDescription)")
      throw RainSDKError.providerError(underlying: error)
    }
  }
}

// MARK: Internal Helpers
extension RainSDKManager {
  /// Validate input parameters before initialization
  func validateInputs(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) throws {
    // Validate token
    guard !portalSessionToken.isEmpty else {
      RainLogger.warning("Rain SDK: Empty portal session token provided")
      throw RainSDKError.unauthorized
    }
  }
  
  /// Build RPC configuration dictionary from NetworkConfig array
  func buildRpcConfig(from networkConfigs: [NetworkConfig]) throws -> [String: String] {
    var config: [String: String] = [:]
    
    for networkConfig in networkConfigs {
      // Validate chain ID
      guard networkConfig.chainId > 0 else {
        throw RainSDKError.invalidConfig(chainId: networkConfig.chainId, rpcUrl: networkConfig.rpcUrl)
      }
      
      // Validate RPC URL format
      guard networkConfig.rpcUrl.isValidHTTPURL() else {
        throw RainSDKError.invalidConfig(chainId: networkConfig.chainId, rpcUrl: networkConfig.rpcUrl)
      }
      
      // Use the eip155ChainId property from NetworkConfig
      config[networkConfig.eip155ChainId] = networkConfig.rpcUrl
      
      RainLogger.debug("Rain SDK: Added network config - Chain ID: \(networkConfig.chainId), RPC: \(networkConfig.rpcUrl)")
    }
    
    return config
  }
}
