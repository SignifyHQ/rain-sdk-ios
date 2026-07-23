import Foundation

/// High-level representation of a wallet transaction returned by `getTransactions`.
/// Vendor-agnostic; adapters (e.g. Portal) map their own transaction type onto this in their module.
public struct WalletTransaction: Codable, Equatable, Sendable {
  /// Represents metadata associated with a transaction.
  public struct Metadata: Codable, Equatable, Sendable {
    /// Timestamp of the block in which the transaction was included (in ISO format).
    public var blockTimestamp: String

    public init(blockTimestamp: String) {
      self.blockTimestamp = blockTimestamp
    }
  }

  public struct Erc1155Metadata: Codable, Equatable, Sendable {
    public let tokenId: String?
    public let value: String?

    public init(tokenId: String?, value: String?) {
      self.tokenId = tokenId
      self.value = value
    }
  }

  public struct RawContract: Codable, Equatable, Sendable {
    /// Value involved in the contract.
    public var value: String?
    /// Address of the contract, if applicable.
    public var address: String?
    /// Decimal representation of the contract value.
    public var decimal: String?

    public init(value: String?, address: String?, decimal: String?) {
      self.value = value
      self.address = address
      self.decimal = decimal
    }
  }

  /// Block number in which the transaction was included.
  public var blockNum: String
  /// Unique identifier of the transaction.
  public var uniqueId: String
  /// Hash of the transaction.
  public var hash: String
  /// Address that initiated the transaction.
  public var from: String
  /// Address that the transaction was sent to.
  public var to: String?
  /// Value transferred in the transaction, in human-readable units (e.g. `1.5` for 1.5 ETH).
  public var value: Decimal?
  /// Token Id of an ERC721 token, if applicable.
  public var erc721TokenId: String?
  /// Metadata of an ERC1155 token, if applicable.
  public var erc1155Metadata: [Erc1155Metadata?]?
  /// Token Id, if applicable.
  public var tokenId: String?
  /// Type of asset involved in the transaction (e.g., ETH).
  public var asset: String?
  /// Category of the transaction (e.g., external).
  public var category: String
  /// Contract details related to the transaction.
  public var rawContract: RawContract?
  /// Metadata associated with the transaction.
  public var metadata: Metadata?
  /// ID of the chain associated with the transaction.
  public var chainId: Int

  public init(
    blockNum: String,
    uniqueId: String,
    hash: String,
    from: String,
    to: String?,
    value: Decimal?,
    erc721TokenId: String?,
    erc1155Metadata: [Erc1155Metadata?]?,
    tokenId: String?,
    asset: String?,
    category: String,
    rawContract: RawContract?,
    metadata: Metadata?,
    chainId: Int
  ) {
    self.blockNum = blockNum
    self.uniqueId = uniqueId
    self.hash = hash
    self.from = from
    self.to = to
    self.value = value
    self.erc721TokenId = erc721TokenId
    self.erc1155Metadata = erc1155Metadata
    self.tokenId = tokenId
    self.asset = asset
    self.category = category
    self.rawContract = rawContract
    self.metadata = metadata
    self.chainId = chainId
  }

  // MARK: - Codable

  private enum CodingKeys: String, CodingKey {
    case blockNum, uniqueId, hash, from, to, value, erc721TokenId, erc1155Metadata,
         tokenId, asset, category, rawContract, metadata, chainId
  }

  /// Custom decoding so `value` accepts either a JSON number or a numeric string. A string is
  /// strict-parsed into `Decimal` (the whole content must be a decimal literal, so hex or
  /// partially numeric strings throw instead of silently truncating); a JSON number is decoded
  /// as `Decimal` directly, which keeps every digit the synthesized encoder emits (no `Double`
  /// round trip). Absent / null decodes as `nil`; any other JSON type throws.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    blockNum = try container.decode(String.self, forKey: .blockNum)
    uniqueId = try container.decode(String.self, forKey: .uniqueId)
    hash = try container.decode(String.self, forKey: .hash)
    from = try container.decode(String.self, forKey: .from)
    to = try container.decodeIfPresent(String.self, forKey: .to)
    if !container.contains(.value) {
      value = nil
    } else if try container.decodeNil(forKey: .value) {
      value = nil
    } else if let string = try? container.decode(String.self, forKey: .value) {
      value = try Self.decimal(
        fromNumericString: string,
        codingPath: container.codingPath + [CodingKeys.value]
      )
    } else {
      value = try container.decode(Decimal.self, forKey: .value)
    }
    erc721TokenId = try container.decodeIfPresent(String.self, forKey: .erc721TokenId)
    erc1155Metadata = try container.decodeIfPresent([Erc1155Metadata?].self, forKey: .erc1155Metadata)
    tokenId = try container.decodeIfPresent(String.self, forKey: .tokenId)
    asset = try container.decodeIfPresent(String.self, forKey: .asset)
    category = try container.decode(String.self, forKey: .category)
    rawContract = try container.decodeIfPresent(RawContract.self, forKey: .rawContract)
    metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
    chainId = try container.decode(Int.self, forKey: .chainId)
  }

  /// Strict-parses a decimal literal: the trimmed string must fully match an optional sign,
  /// digits, an optional fraction, and an optional exponent. Anything else (hex like `"0x123"`,
  /// trailing junk, empty) throws `DecodingError.dataCorrupted` instead of being accepted as a
  /// partial parse.
  private static func decimal(
    fromNumericString raw: String,
    codingPath: [CodingKey]
  ) throws -> Decimal {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    let pattern = "^[+-]?[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?$"
    guard trimmed.range(of: pattern, options: .regularExpression) != nil,
          let parsed = Decimal(string: trimmed, locale: Locale(identifier: "en_US_POSIX")) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "value string \"\(raw)\" is not a decimal number"
        )
      )
    }
    return parsed
  }
}

