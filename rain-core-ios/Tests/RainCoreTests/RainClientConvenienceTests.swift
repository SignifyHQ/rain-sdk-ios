import Testing
import CoreGraphics
import Foundation
import Web3
@testable import RainCore

/// Pins the `RainClient` convenience overloads to the protocol requirement.
///
/// `getTransactions` deliberately has NO full-signature extension member: one with the
/// requirement's exact signature would act as a default witness whose body dispatches back to
/// itself, so a conformance omitting the method would compile and then recurse forever. With
/// only the reduced-arity convenience below, omitting `getTransactions(chainId:limit:offset:order:)`
/// from a conformance fails to compile — which is the guarantee this suite documents.
@Suite("RainClient Convenience Overloads")
struct RainClientConvenienceTests {

  @Test("getTransactions(chainId:) forwards nil paging and order to the requirement")
  func getTransactionsConvenienceForwards() async throws {
    let spy = SpyRainClient()
    let client: any RainClient = spy

    _ = try await client.getTransactions(chainId: 137)

    let call = try #require(spy.getTransactionsCalls.first)
    #expect(spy.getTransactionsCalls.count == 1)
    #expect(call.chainId == 137)
    #expect(call.limit == nil)
    #expect(call.offset == nil)
    #expect(call.order == nil)
  }

  @Test("full-arity getTransactions reaches the witness unchanged")
  func fullArityReachesWitness() async throws {
    let spy = SpyRainClient()
    let client: any RainClient = spy

    _ = try await client.getTransactions(chainId: 1, limit: 20, offset: 5, order: .DESC)

    let call = try #require(spy.getTransactionsCalls.first)
    #expect(call.chainId == 1)
    #expect(call.limit == 20)
    #expect(call.offset == 5)
    #expect(call.order == .DESC)
  }
}

/// Minimal conformance: records `getTransactions` calls; everything unused traps.
private final class SpyRainClient: RainClient, @unchecked Sendable {
  struct GetTransactionsCall {
    let chainId: Int
    let limit: Int?
    let offset: Int?
    let order: RainTransactionOrder?
  }

  private let lock = NSLock()
  private var _getTransactionsCalls: [GetTransactionsCall] = []
  var getTransactionsCalls: [GetTransactionsCall] {
    lock.lock(); defer { lock.unlock() }
    return _getTransactionsCalls
  }

  var providerId: ProviderId { ProviderId("spy") }
  var capabilities: Set<Capability> { [] }
  var isInitialized: Bool { true }
  func reset() {}

  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: RainTransactionOrder?
  ) async throws -> [RainTransaction] {
    lock.withLock {
      _getTransactionsCalls.append(
        GetTransactionsCall(chainId: chainId, limit: limit, offset: offset, order: order)
      )
    }
    return []
  }

  func withdrawCollateral(
    chainId: Int, addresses: RainWithdrawAddresses, amount: Decimal, decimals: Int,
    adminSignature: RainAdminSignature, nonce: BigUInt?
  ) async throws -> String { fatalError("unused") }

  func prepareWithdrawal(
    chainId: Int, addresses: RainWithdrawAddresses, amount: Decimal, decimals: Int,
    adminSignature: RainAdminSignature, nonce: BigUInt?
  ) async throws -> RainPreparedWithdrawal { fatalError("unused") }

  func estimateGas(chainId: Int, from: String, to: String, data: String) async throws -> Decimal {
    fatalError("unused")
  }

  func estimateWithdrawalFee(
    chainId: Int, addresses: RainWithdrawAddresses, amount: Decimal, decimals: Int,
    adminSignature: RainAdminSignature, nonce: BigUInt?
  ) async throws -> Decimal { fatalError("unused") }

  func getWalletAddress() async throws -> String { fatalError("unused") }
  func getWalletAddress(chainId: Int) async throws -> String { fatalError("unused") }

  func generateWalletAddressQRCode(
    dimension: Int, backgroundColor: CGColor?, foregroundColor: CGColor?
  ) async throws -> Data { fatalError("unused") }

  func generateAddressQRCode(
    address: String?, dimension: Int, backgroundColor: CGColor?, foregroundColor: CGColor?
  ) async throws -> Data { fatalError("unused") }

  func getBalance(chainId: Int, token: Token) async throws -> Balance { fatalError("unused") }
  func getTokenBalances(chainId: Int) async throws -> [Balance] { fatalError("unused") }
  func getAllBalances() async throws -> [Balance] { fatalError("unused") }

  func sendNative(chainId: Int, to: String, amount: Decimal) async throws -> RainTokenTransferResult {
    fatalError("unused")
  }

  func sendToken(
    chainId: Int, contractAddress: String, to: String, amount: Decimal, decimals: Int?
  ) async throws -> RainTokenTransferResult { fatalError("unused") }

  func registerTokens(_ tokens: [TokenInfo]) {}
}
