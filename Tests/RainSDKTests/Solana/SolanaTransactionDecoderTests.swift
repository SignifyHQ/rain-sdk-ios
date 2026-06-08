import Testing
import Foundation
@testable import RainSDK

@Suite("SolanaTransactionDecoder")
struct SolanaTransactionDecoderTests {
  let from = Base58.encode((0..<32).map { UInt8($0 + 1) })
  let to = Base58.encode((0..<32).map { UInt8($0 + 33) })
  let blockhash = Base58.encode((0..<32).map { UInt8($0 + 65) })

  @Test("decodes the transfer the builder produced")
  func decodesBuilderOutput() throws {
    let lamports: UInt64 = 1_234_500_000
    let hex = try SolanaTransactionBuilder.buildTransferHex(
      from: from, to: to, lamports: lamports, recentBlockhash: blockhash)
    let decoded = SolanaTransactionDecoder.decodeTransfer(hex)
    #expect(decoded?.from == from)
    #expect(decoded?.to == to)
    #expect(decoded?.lamports == lamports)
  }

  @Test("tolerates an optional 0x prefix")
  func tolerates0xPrefix() throws {
    let hex = try SolanaTransactionBuilder.buildTransferHex(
      from: from, to: to, lamports: 1, recentBlockhash: blockhash)
    #expect(SolanaTransactionDecoder.decodeTransfer("0x" + hex)?.lamports == 1)
  }

  @Test("returns nil for non-hex or undecodable input")
  func returnsNilForBadInput() {
    #expect(SolanaTransactionDecoder.decodeTransfer("not-hex!!") == nil)
    #expect(SolanaTransactionDecoder.decodeTransfer("abcd") == nil)
  }
}
