import Foundation
import RainSDK

/// The network the demo app operates on, selected via the dropdown on the connection screen.
/// Mirrors the Android sample's WalletChain enum; the SDK is initialized with every entry's
/// RPC endpoint at once (see `networkConfigs`), so switching chains needs no re-init.
enum WalletChain: String, CaseIterable, Identifiable {
  case avalancheFuji
  case baseSepolia
  case solanaDevnet

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .avalancheFuji: return "EVM · Avalanche Fuji"
    case .baseSepolia: return "EVM · Base Sepolia"
    case .solanaDevnet: return "Solana · Devnet"
    }
  }

  var chainId: Int {
    switch self {
    case .avalancheFuji: return 43113
    case .baseSepolia: return 84532
    case .solanaDevnet: return 103 // Solana devnet sentinel
    }
  }

  var rpcUrl: String {
    switch self {
    case .avalancheFuji: return "https://api.avax-test.network/ext/bc/C/rpc"
    case .baseSepolia: return "https://sepolia.base.org"
    case .solanaDevnet: return "https://api.devnet.solana.com"
    }
  }

  var nativeSymbol: String {
    switch self {
    case .avalancheFuji: return "AVAX"
    case .baseSepolia: return "ETH"
    case .solanaDevnet: return "SOL"
    }
  }

  var isSolana: Bool { self == .solanaDevnet }

  /// Block-explorer name, e.g. for a "View on Snowtrace" label.
  var explorerName: String {
    switch self {
    case .avalancheFuji: return "Snowtrace"
    case .baseSepolia: return "Basescan"
    case .solanaDevnet: return "Solana Explorer"
    }
  }

  private var explorerBase: String {
    switch self {
    case .avalancheFuji: return "https://testnet.snowtrace.io"
    case .baseSepolia: return "https://sepolia.basescan.org"
    case .solanaDevnet: return "https://explorer.solana.com"
    }
  }

  private var explorerSuffix: String {
    isSolana ? "?cluster=devnet" : ""
  }

  func explorerTxURL(hash: String) -> URL? {
    URL(string: "\(explorerBase)/tx/\(hash)\(explorerSuffix)")
  }

  func explorerAddressURL(address: String) -> URL? {
    URL(string: "\(explorerBase)/address/\(address)\(explorerSuffix)")
  }

  /// Light client-side address sanity check (the SDK validates authoritatively).
  func isValidAddress(_ address: String) -> Bool {
    guard !address.isEmpty else { return false }
    if isSolana {
      return (32...44).contains(address.count)
        && address.allSatisfy { Self.base58Alphabet.contains($0) }
    }
    return address.hasPrefix("0x")
      && address.count == 42
      && address.dropFirst(2).allSatisfy { $0.isHexDigit }
  }

  /// Every chain's NetworkConfig, for initializing the SDK with all chains at once.
  static var networkConfigs: [NetworkConfig] {
    allCases.map {
      NetworkConfig(chainId: $0.chainId, rpcUrl: $0.rpcUrl, networkName: $0.displayName)
    }
  }

  static func from(chainId: Int) -> WalletChain? {
    allCases.first { $0.chainId == chainId }
  }

  private static let base58Alphabet =
    Set("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
}
