import Foundation

/// Minimal decoder for the unsigned legacy Solana transactions produced by
/// `SolanaTransactionBuilder`. Turnkey's `sol_send_transaction` activity stores only the
/// unsigned transaction — no recipient or amount — so transaction history recovers the
/// System-transfer's destination and lamports by parsing that blob.
///
/// Reverses the builder's wire format: compact-u16 signature count + zero-filled signatures +
/// message (header, account keys, blockhash, instructions). Returns `nil` if the bytes aren't
/// a decodable transaction containing a System `transfer`.
internal enum SolanaTransactionDecoder {
  private static let publicKeyLength = 32
  private static let signatureLength = 64
  private static let systemProgramId = [UInt8](repeating: 0, count: 32)
  private static let systemTransferInstructionIndex: UInt64 = 2

  struct Transfer: Equatable {
    let from: String
    let to: String
    let lamports: UInt64
  }

  /// Decodes the unsigned transaction (hex, or base64 as a fallback). Returns `nil` on any
  /// parse failure or if the transaction isn't a System transfer.
  static func decodeTransfer(_ unsignedTransaction: String) -> Transfer? {
    guard let bytes = hexToBytes(unsignedTransaction) ?? base64ToBytes(unsignedTransaction) else {
      return nil
    }
    return try? parse(bytes)
  }

  private static func parse(_ bytes: [UInt8]) throws -> Transfer? {
    let reader = Reader(bytes)

    // Signature section: count + count * 64-byte placeholders.
    let signatureCount = try reader.readCompactU16()
    try reader.skip(signatureCount * signatureLength)

    // Message header (3 bytes), unused here.
    _ = try reader.readByte()
    _ = try reader.readByte()
    _ = try reader.readByte()

    // Account keys.
    let accountCount = try reader.readCompactU16()
    var accounts: [[UInt8]] = []
    accounts.reserveCapacity(accountCount)
    for _ in 0..<accountCount { accounts.append(try reader.readBytes(publicKeyLength)) }

    // Recent blockhash.
    try reader.skip(publicKeyLength)

    // Instructions — find the System transfer.
    let instructionCount = try reader.readCompactU16()
    for _ in 0..<instructionCount {
      let programIdIndex = try reader.readByte()
      let accountIndexCount = try reader.readCompactU16()
      var accountIndices: [Int] = []
      accountIndices.reserveCapacity(accountIndexCount)
      for _ in 0..<accountIndexCount { accountIndices.append(try reader.readByte()) }
      let dataLen = try reader.readCompactU16()
      let data = try reader.readBytes(dataLen)

      let programId = accounts.indices.contains(programIdIndex) ? accounts[programIdIndex] : nil
      let isSystemTransfer = programId == systemProgramId
        && data.count >= 12
        && readU32LE(data, offset: 0) == systemTransferInstructionIndex
      if isSystemTransfer {
        guard accountIndices.count >= 2,
              accounts.indices.contains(accountIndices[0]),
              accounts.indices.contains(accountIndices[1]) else {
          return nil
        }
        return Transfer(
          from: Base58.encode(accounts[accountIndices[0]]),
          to: Base58.encode(accounts[accountIndices[1]]),
          lamports: readU64LE(data, offset: 4)
        )
      }
    }
    return nil
  }

  private final class Reader {
    private let bytes: [UInt8]
    private var pos = 0

    init(_ bytes: [UInt8]) { self.bytes = bytes }

    func readByte() throws -> Int {
      guard pos < bytes.count else {
        throw RainSDKError.internalLogicError(details: "Unexpected end of transaction")
      }
      defer { pos += 1 }
      return Int(bytes[pos])
    }

    func readBytes(_ length: Int) throws -> [UInt8] {
      guard pos + length <= bytes.count else {
        throw RainSDKError.internalLogicError(details: "Unexpected end of transaction")
      }
      defer { pos += length }
      return Array(bytes[pos..<pos + length])
    }

    func skip(_ length: Int) throws {
      guard pos + length <= bytes.count else {
        throw RainSDKError.internalLogicError(details: "Unexpected end of transaction")
      }
      pos += length
    }

    /// Solana short-vec (compact-u16): 7 bits per byte, MSB = continuation.
    func readCompactU16() throws -> Int {
      var result = 0
      var shift = 0
      while true {
        let b = try readByte()
        result |= (b & 0x7F) << shift
        if b & 0x80 == 0 { break }
        shift += 7
      }
      return result
    }
  }

  private static func readU32LE(_ data: [UInt8], offset: Int) -> UInt64 {
    var value: UInt64 = 0
    for i in 0..<4 {
      let byte = UInt64(truncatingIfNeeded: data[offset + i])
      value |= byte << (i * 8)
    }
    return value
  }

  private static func readU64LE(_ data: [UInt8], offset: Int) -> UInt64 {
    var value: UInt64 = 0
    for i in 0..<8 {
      let byte = UInt64(truncatingIfNeeded: data[offset + i])
      value |= byte << (i * 8)
    }
    return value
  }

  private static func hexToBytes(_ hex: String) -> [UInt8]? {
    let clean = hex.hasPrefix("0x") || hex.hasPrefix("0X") ? String(hex.dropFirst(2)) : hex
    guard !clean.isEmpty, clean.count % 2 == 0 else { return nil }
    var out: [UInt8] = []
    out.reserveCapacity(clean.count / 2)
    var index = clean.startIndex
    while index < clean.endIndex {
      let next = clean.index(index, offsetBy: 2)
      guard let byte = UInt8(clean[index..<next], radix: 16) else { return nil }
      out.append(byte)
      index = next
    }
    return out
  }

  private static func base64ToBytes(_ string: String) -> [UInt8]? {
    guard let data = Data(base64Encoded: string), !data.isEmpty else { return nil }
    return [UInt8](data)
  }
}
