import Foundation
import PrivySDK

/// Narrow seam over the Privy SDK — the operations ``PrivyManager`` needs.
protocol PrivyWalletSource: Sendable {
  /// The authenticated user's embedded Ethereum wallets, or `nil` when no user is authenticated
  /// (distinct from `[]`, which means an authenticated user with no wallet yet).
  func embeddedEthereumWallets() async -> [any PrivyEthereumSigner]?
}

/// The signing surface of one Privy embedded Ethereum wallet.
protocol PrivyEthereumSigner: Sendable {
  var address: String { get }
  func request(_ request: EthereumRpcRequest) async throws -> String
  func switchChain(chainId: Int, rpcUrl: String?) async
}

/// Production `PrivyWalletSource` backed by the real Privy singleton.
struct LivePrivyWalletSource: PrivyWalletSource {
  let privy: any Privy

  func embeddedEthereumWallets() async -> [any PrivyEthereumSigner]? {
    guard let user = await privy.getUser() else { return nil }
    return user.embeddedEthereumWallets.map(LivePrivyEthereumSigner.init)
  }
}

/// Production `PrivyEthereumSigner` wrapping a real embedded wallet.
struct LivePrivyEthereumSigner: PrivyEthereumSigner {
  let wallet: any EmbeddedEthereumWallet

  var address: String { wallet.address }

  func request(_ request: EthereumRpcRequest) async throws -> String {
    try await wallet.provider.request(request)
  }

  func switchChain(chainId: Int, rpcUrl: String?) async {
    await wallet.provider.switchChain(chainId: chainId, rpcUrl: rpcUrl)
  }
}
