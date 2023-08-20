import Foundation

public struct CryptoReceipt {
  public let id: String
  public let accountId: String
  public let fee: Double?
  public let completedAt: String?
  public let tradingPair: String?
  public let currency: String?
  public let orderType: CryptoOrderType
  public let size: Double?
  public let exchangeRate: Double?
  public let transactionValue: Double?
  
  public init(
    id: String,
    accountId: String,
    fee: Double?,
    completedAt: String?,
    tradingPair: String?,
    currency: String?,
    orderType: String?,
    size: Double?,
    exchangeRate: Double?,
    transactionValue: Double?
  ) {
    self.id = id
    self.accountId = accountId
    self.fee = fee
    self.completedAt = completedAt
    self.tradingPair = tradingPair
    self.currency = currency
    self.orderType = CryptoOrderType(rawValue: orderType ?? "UNKNOWN") ?? .unknow
    self.size = size
    self.exchangeRate = exchangeRate
    self.transactionValue = transactionValue
  }
}

public enum CryptoOrderType: String {
  case unknow = "UNKNOWN"
  case buy = "BUY"
  case sell = "SELL"
  case withdraw = "WITHDRAW"
  case deposit = "DEPOSIT"
  
  public var isTransfer: Bool {
    switch self {
    case .deposit, .withdraw:
      return true
    default:
      return false
    }
  }
  
  public var title: String {
    switch self {
    case .withdraw:
      return "WITHDRAWAL"
    default:
      return rawValue
    }
  }
}
