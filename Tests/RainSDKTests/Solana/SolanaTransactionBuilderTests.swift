import Testing
import Foundation
@testable import RainSDK

/// Pins the exact byte layout of the unsigned legacy transfer transaction handed to Turnkey,
/// matching `@solana/web3.js` `Transaction.serialize({ requireAllSignatures: false })`.
@Suite("SolanaTransactionBuilder")
struct SolanaTransactionBuilderTests {
  let fromBytes = (0..<32).map { UInt8($0 + 1) }
  let toBytes = (0..<32).map { UInt8($0 + 33) }
  let blockhashBytes = (0..<32).map { UInt8($0 + 65) }
  var from: String { Base58.encode(fromBytes) }
  var to: String { Base58.encode(toBytes) }
  var blockhash: String { Base58.encode(blockhashBytes) }

  @Test("compactU16 encodes small and multi-byte lengths")
  func compactU16() {
    #expect(SolanaTransactionBuilder.compactU16(0) == [0])
    #expect(SolanaTransactionBuilder.compactU16(1) == [1])
    #expect(SolanaTransactionBuilder.compactU16(127) == [127])
    #expect(SolanaTransactionBuilder.compactU16(128) == [0x80, 0x01])
  }

  @Test("serialized transfer has the exact expected layout")
  func exactLayout() throws {
    let tx = try SolanaTransactionBuilder.buildTransferBytes(
      from: from, to: to, lamports: 1_000_000_000, recentBlockhash: blockhash)
    var i = 0
    #expect(tx[i] == 1); i += 1
    #expect(Array(tx[i..<i+64]) == [UInt8](repeating: 0, count: 64)); i += 64
    #expect(tx[i] == 1); i += 1
    #expect(tx[i] == 0); i += 1
    #expect(tx[i] == 1); i += 1
    #expect(tx[i] == 3); i += 1
    #expect(Array(tx[i..<i+32]) == fromBytes); i += 32
    #expect(Array(tx[i..<i+32]) == toBytes); i += 32
    #expect(Array(tx[i..<i+32]) == [UInt8](repeating: 0, count: 32)); i += 32
    #expect(Array(tx[i..<i+32]) == blockhashBytes); i += 32
    #expect(tx[i] == 1); i += 1
    #expect(tx[i] == 2); i += 1
    #expect(tx[i] == 2); i += 1
    #expect(tx[i] == 0); i += 1
    #expect(tx[i] == 1); i += 1
    #expect(tx[i] == 12); i += 1
    #expect(Array(tx[i..<i+4]) == [2, 0, 0, 0]); i += 4
    #expect(Array(tx[i..<i+8]) == [0x00, 0xCA, 0x9A, 0x3B, 0, 0, 0, 0]); i += 8
    #expect(i == tx.count)
    #expect(tx.count == 215)
  }

  @Test("buildTransferHex emits lowercase hex of the serialized bytes")
  func hexMatchesBytes() throws {
    let bytes = try SolanaTransactionBuilder.buildTransferBytes(
      from: from, to: to, lamports: 1_000_000_000, recentBlockhash: blockhash)
    let hex = try SolanaTransactionBuilder.buildTransferHex(
      from: from, to: to, lamports: 1_000_000_000, recentBlockhash: blockhash)
    let expected = bytes.map { String(format: "%02x", $0) }.joined()
    #expect(hex == expected)
    #expect(hex.allSatisfy { "0123456789abcdef".contains($0) })
  }

  @Test("rejects non-32-byte addresses")
  func rejectsBadAddress() {
    let tooShort = Base58.encode([UInt8](repeating: 0, count: 31))
    #expect(throws: RainSDKError.self) {
      _ = try SolanaTransactionBuilder.buildTransferHex(
        from: tooShort, to: to, lamports: 1, recentBlockhash: blockhash)
    }
  }
}
