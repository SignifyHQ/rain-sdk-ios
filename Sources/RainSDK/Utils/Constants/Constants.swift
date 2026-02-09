import Foundation

enum Constants {
  /// Chain ID format types
  /// Currently supports EIP-155, can be extended for other formats in the future
  enum ChainIDFormat {
    case EIP155
    
    /// Get the namespace prefix for the format
    var prefix: String {
      switch self {
      case .EIP155:
        return "eip155"
      }
    }
    
    /// Format a chain ID as a string in this format
    /// - Parameter chainId: The chain ID as an integer
    /// - Returns: Formatted string (e.g., "eip155:1")
    func format(chainId: Int) -> String {
      switch self {
      case .EIP155:
        return "\(prefix):\(chainId)"
      }
    }
    
    /// Parse a formatted string to extract the chain ID
    /// - Parameter string: Formatted string (e.g., "eip155:1")
    /// - Returns: The chain ID as an integer, or nil if format is invalid
    func parse(_ string: String) -> Int? {
      switch self {
      case .EIP155:
        let components = string.components(separatedBy: ":")
        guard components.count == 2,
              components[0] == prefix,
              let chainId = Int(components[1]) else {
          return nil
        }
        return chainId
      }
    }
    
    /// Check if a string is valid for this format
    /// - Parameter string: String to validate
    /// - Returns: true if the string matches this format
    func isValid(_ string: String) -> Bool {
      return parse(string) != nil
    }
  }
  
  /// Contract ABI JSON names
  /// Used to identify contract ABIs for encoding/decoding operations
  enum ContractABI {
    /// Main contract ABI JSON name
    static let contractJsonABI = "contractJsonABI"
    
    /// Collateral contract ABI JSON name
    static let collateralJsonABI = "collateralJsonABI"
  }
}
