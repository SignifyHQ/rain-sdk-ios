import Foundation

/// Network configuration for Portal wallet SDK
public struct NetworkConfig {
  /// The network/chain identifier as an integer (EIP-155 chain ID)
  /// Examples: 1 (Ethereum Mainnet), 137 (Polygon), 42161 (Arbitrum)
  public let chainId: Int
  
  /// The RPC endpoint URL for the network
  public let rpcUrl: String
  
  /// Optional network name for display purposes
  public let networkName: String?
  
  /// EIP-155 formatted chain ID (e.g., "eip155:1", "eip155:137")
  public var eip155ChainId: String {
    return Constants.ChainIDFormat.EIP155.format(chainId: chainId)
  }
  
  /// Initialize network configuration with integer chain ID
  /// - Parameters:
  ///   - chainId: The chain identifier as an integer (EIP-155 format)
  ///   - rpcUrl: The RPC endpoint URL
  ///   - networkName: Optional network name
  ///   - customParams: Optional custom parameters
  public init(
    chainId: Int,
    rpcUrl: String,
    networkName: String? = nil
  ) {
    self.chainId = chainId
    self.rpcUrl = rpcUrl
    self.networkName = networkName
  }
  
  /// Initialize network configuration with EIP-155 formatted chain ID string
  /// - Parameters:
  ///   - eip155ChainId: The chain identifier in EIP-155 format (e.g., "eip155:1", "eip155:137")
  ///   - rpcUrl: The RPC endpoint URL
  ///   - networkName: Optional network name
  ///   - customParams: Optional custom parameters
  /// - Throws: Error if the eip155ChainId format is invalid
  public init(
    eip155ChainId: String,
    rpcUrl: String,
    networkName: String? = nil
  ) throws {
    // Parse eip155: prefix format
    let components = eip155ChainId.components(separatedBy: ":")
    guard components.count == 2,
          components[0] == Constants.ChainIDFormat.EIP155.prefix,
          let chainIdInt = Int(components[1]) else {
      throw NetworkConfigError.invalidEIP155Format(eip155ChainId)
    }
    
    self.chainId = chainIdInt
    self.rpcUrl = rpcUrl
    self.networkName = networkName
  }
}

/// Errors related to NetworkConfig
public enum NetworkConfigError: Error, LocalizedError, Equatable {
  case invalidEIP155Format(String)
  
  public var errorDescription: String? {
    switch self {
    case .invalidEIP155Format(let format):
      return "Invalid EIP-155 chain ID format: \(format). Expected format: 'eip155:<chainId>'"
    }
  }
}

extension NetworkConfig: Equatable {
  public static func == (lhs: NetworkConfig, rhs: NetworkConfig) -> Bool {
    return lhs.chainId == rhs.chainId &&
    lhs.rpcUrl == rhs.rpcUrl &&
    lhs.networkName == rhs.networkName
  }
}
