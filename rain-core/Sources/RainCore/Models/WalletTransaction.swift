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
  /// Value transferred in the transaction.
  public var value: Double?
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
    value: Double?,
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
}

