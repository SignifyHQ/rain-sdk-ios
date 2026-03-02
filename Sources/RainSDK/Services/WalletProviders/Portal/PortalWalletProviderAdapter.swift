import Foundation
import PortalSwift

/// Portal-based implementation of `RainWalletProvider`.
/// Used when the SDK is initialized with `initializePortal(...)`.
internal final class PortalWalletProviderAdapter: RainWalletProvider, @unchecked Sendable {
  private let portal: PortalRequestProtocol

  internal init(portal: PortalRequestProtocol) {
    self.portal = portal
  }

  public func address(
  ) async throws -> String {
    let addresses = try await portal.addresses
    let eip155 = PortalNamespace.eip155
    
    guard let addr = addresses[eip155] ?? nil, !addr.isEmpty else {
      throw RainSDKError.walletUnavailable
    }
    
    return addr
  }

  public func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String {
    let ethParam = ETHTransactionParam(
      from: params.from,
      to: params.to,
      value: params.value,
      data: params.data
    )
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
    
    let response = try await portal.request(
      chainId: chainIdString,
      method: .eth_sendTransaction,
      params: [ethParam],
      options: nil
    )
    
    guard let txHash = response.result as? String else {
      throw RainSDKError.internalLogicError(details: "eth_sendTransaction returned no transaction hash")
    }
    
    return txHash
  }
}
