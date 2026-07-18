import Foundation

/// A collateral contract returned by `GET /v1/issuing/users/{userId}/contracts`.
/// Mirrors Android's `RainCollateralContract`.
public struct RainCollateralContract: Sendable, Hashable {
  /// Rain's identifier for the contract, when present.
  public let id: String?

  /// EIP-155 chain ID the contract is deployed on.
  public let chainId: Int

  /// The collateral proxy contract address (the address funds are held at).
  public let proxyAddress: String

  /// The collateral controller contract address.
  public let controllerAddress: String

  /// Optional dedicated deposit address, when Rain provides one.
  public let depositAddress: String?

  /// Admin addresses of the collateral contract; one of these is passed to
  /// `fetchAdminSignature`.
  public let adminAddresses: [String]

  /// Rain's contract version, when present.
  public let contractVersion: Int?

  /// Collateral tokens held by the contract.
  public let tokens: [RainCollateralToken]

  public init(
    id: String?,
    chainId: Int,
    proxyAddress: String,
    controllerAddress: String,
    depositAddress: String?,
    adminAddresses: [String],
    contractVersion: Int?,
    tokens: [RainCollateralToken]
  ) {
    self.id = id
    self.chainId = chainId
    self.proxyAddress = proxyAddress
    self.controllerAddress = controllerAddress
    self.depositAddress = depositAddress
    self.adminAddresses = adminAddresses
    self.contractVersion = contractVersion
    self.tokens = tokens
  }
}

/// A collateral token entry within a ``RainCollateralContract``.
///
/// The contracts endpoint returns only `address` / `balance` / `exchangeRate` / `advanceRate`;
/// the SDK enriches `name` / `symbol` / `decimals` from its token store (registry,
/// host-registered tokens, or an on-chain read). Enrichment is best-effort — a failed lookup
/// leaves those fields `nil` rather than failing the fetch.
public struct RainCollateralToken: Sendable, Hashable {
  public let address: String

  /// Raw balance string exactly as returned by the Rain API (e.g. "0.0").
  public let balance: String

  public let exchangeRate: Double
  public let advanceRate: Double
  public let name: String?
  public let symbol: String?
  public let decimals: Int?

  /// `balance` as a decimal, or `nil` when it doesn't parse.
  public var balanceAmount: Decimal? { Decimal(string: balance) }

  public init(
    address: String,
    balance: String,
    exchangeRate: Double,
    advanceRate: Double,
    name: String? = nil,
    symbol: String? = nil,
    decimals: Int? = nil
  ) {
    self.address = address
    self.balance = balance
    self.exchangeRate = exchangeRate
    self.advanceRate = advanceRate
    self.name = name
    self.symbol = symbol
    self.decimals = decimals
  }
}
