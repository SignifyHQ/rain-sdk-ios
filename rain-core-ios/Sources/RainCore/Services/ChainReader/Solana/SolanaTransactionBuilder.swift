import Foundation

/// Builds the **unsigned** Solana transaction that Turnkey's `sol_send_transaction` activity
/// expects (it decodes and parses the unsigned payload, signs it with the wallet's ed25519
/// key, and broadcasts).
///
/// NOTE on encoding: the Turnkey Swift type documents `unsignedTransaction` as "base64", but
/// the live API hex-decodes the field, so the adapter sends `serializedHex` by default. Both
/// `serializedHex` and `serializedBase64` are exposed so flipping the encoding is one line.
///
/// Scope is a single native SOL transfer (System Program `transfer`). The wire format matches
/// `@solana/web3.js` `Transaction.serialize({ requireAllSignatures: false })`: a legacy
/// transaction = compact-u16 signature count + one zero-filled 64-byte signature placeholder +
/// the serialized message. Turnkey fills the placeholder with the real signature.
///
/// Pure and dependency-free so it can be unit-tested byte-for-byte.
internal enum SolanaTransactionBuilder {
  private static let publicKeyLength = 32
  private static let signatureLength = 64
  private static let systemProgramId = [UInt8](repeating: 0, count: 32) // all-zero account = 1111…1111
  private static let systemTransferInstructionIndex: UInt32 = 2 // SystemInstruction::Transfer

  /// Lowercase hex of the serialized unsigned transaction.
  static func buildTransferHex(
    from fromAddress: String,
    to toAddress: String,
    lamports: UInt64,
    recentBlockhash: String
  ) throws -> String {
    toHex(try buildTransferBytes(from: fromAddress, to: toAddress, lamports: lamports, recentBlockhash: recentBlockhash))
  }

  /// Base64 of the serialized unsigned transaction (per the Turnkey type's documented encoding).
  static func buildTransferBase64(
    from fromAddress: String,
    to toAddress: String,
    lamports: UInt64,
    recentBlockhash: String
  ) throws -> String {
    Data(try buildTransferBytes(from: fromAddress, to: toAddress, lamports: lamports, recentBlockhash: recentBlockhash)).base64EncodedString()
  }

  static func buildTransferBytes(
    from fromAddress: String,
    to toAddress: String,
    lamports: UInt64,
    recentBlockhash: String
  ) throws -> [UInt8] {
    let from = try decodeKey(fromAddress, label: "from")
    let to = try decodeKey(toAddress, label: "to")
    let blockhash = try decodeKey(recentBlockhash, label: "recentBlockhash")

    let message = serializeMessage(from: from, to: to, blockhash: blockhash, lamports: lamports)

    var tx: [UInt8] = []
    // Signature section: one required signature (the fee payer), zero-filled placeholder.
    tx.append(contentsOf: compactU16(1))
    tx.append(contentsOf: [UInt8](repeating: 0, count: signatureLength))
    tx.append(contentsOf: message)
    return tx
  }

  private static func serializeMessage(
    from: [UInt8],
    to: [UInt8],
    blockhash: [UInt8],
    lamports: UInt64
  ) -> [UInt8] {
    // Account ordering rule: writable-signers, readonly-signers, writable-nonsigners,
    // readonly-nonsigners. For a transfer that's [from, to, systemProgram].
    var out: [UInt8] = []

    // Message header.
    out.append(1) // numRequiredSignatures (fee payer)
    out.append(0) // numReadonlySignedAccounts
    out.append(1) // numReadonlyUnsignedAccounts (the System Program)

    // Account keys.
    out.append(contentsOf: compactU16(3))
    out.append(contentsOf: from)
    out.append(contentsOf: to)
    out.append(contentsOf: systemProgramId)

    // Recent blockhash.
    out.append(contentsOf: blockhash)

    // Instructions (exactly one: the transfer).
    out.append(contentsOf: compactU16(1))
    out.append(2) // programIdIndex -> systemProgramId at account index 2
    out.append(contentsOf: compactU16(2)) // account indices used by the instruction
    out.append(0) // from
    out.append(1) // to
    let data = transferInstructionData(lamports: lamports)
    out.append(contentsOf: compactU16(data.count))
    out.append(contentsOf: data)

    return out
  }

  /// SystemProgram transfer data: u32 LE instruction index (2) followed by u64 LE lamports.
  private static func transferInstructionData(lamports: UInt64) -> [UInt8] {
    var data = [UInt8](repeating: 0, count: 12)
    writeU32LE(&data, offset: 0, value: systemTransferInstructionIndex)
    writeU64LE(&data, offset: 4, value: lamports)
    return data
  }

  private static func decodeKey(_ address: String, label: String) throws -> [UInt8] {
    let bytes: [UInt8]
    do {
      bytes = try Base58.decode(address)
    } catch {
      throw RainSDKError.internalLogicError(details: "Invalid Solana \(label) address: \(address)")
    }
    guard bytes.count == publicKeyLength else {
      throw RainSDKError.internalLogicError(
        details: "Invalid Solana \(label) address (expected 32 bytes, got \(bytes.count)): \(address)"
      )
    }
    return bytes
  }

  /// Solana short-vec (compact-u16) length encoding: 7 bits per byte, MSB = continuation.
  static func compactU16(_ value: Int) -> [UInt8] {
    precondition(value >= 0 && value <= 0xFFFF, "compact-u16 out of range: \(value)")
    var out: [UInt8] = []
    var remaining = value
    while true {
      let low = remaining & 0x7F
      remaining >>= 7
      if remaining == 0 {
        out.append(UInt8(low))
        break
      }
      out.append(UInt8(low | 0x80))
    }
    return out
  }

  private static func writeU32LE(_ target: inout [UInt8], offset: Int, value: UInt32) {
    var v = value
    for i in 0..<4 {
      target[offset + i] = UInt8(truncatingIfNeeded: v)
      v >>= 8
    }
  }

  private static func writeU64LE(_ target: inout [UInt8], offset: Int, value: UInt64) {
    var v = value
    for i in 0..<8 {
      target[offset + i] = UInt8(truncatingIfNeeded: v)
      v >>= 8
    }
  }

  private static func toHex(_ bytes: [UInt8]) -> String {
    let digits = Array("0123456789abcdef")
    var chars: [Character] = []
    chars.reserveCapacity(bytes.count * 2)
    for b in bytes {
      chars.append(digits[Int(b >> 4)])
      chars.append(digits[Int(b & 0x0F)])
    }
    return String(chars)
  }
}
