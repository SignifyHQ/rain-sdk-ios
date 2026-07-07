import Foundation
import RainCore

/// Privy ``RainWalletProvider`` — **skeleton**.
///
/// Implements the port so the module compiles and registers, but every operation throws
/// `RainSDKError.internalLogicError` until the Privy embedded-wallet SDK is integrated. This is the
/// single file that will own all Privy-specific signing once the adapter is built.
internal final class PrivyWalletProvider: RainWalletProvider, @unchecked Sendable {
  private func notImplemented() throws -> Never {
    throw RainSDKError.internalLogicError(
      details: "rain-privy is a skeleton; the Privy adapter is not implemented yet"
    )
  }

  func address() async throws -> String { try notImplemented() }

  func getAddress(chainId: Int) async throws -> String { try notImplemented() }

  func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String { try notImplemented() }

  func getBalance(chainId: Int, token: Token) async throws -> Balance { try notImplemented() }

  func getBalances(chainId: Int) async throws -> [Balance] { try notImplemented() }

  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] { try notImplemented() }
}
