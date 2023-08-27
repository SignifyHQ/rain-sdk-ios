import Foundation
import CryptoChartDomain

public struct APICMCSymbolHistories: Codable {
  public let currency: String
  public let interval: String
  public let timestamp: String?
  public let open: Double?
  public let close: Double?
  public let high: Double?
  public let low: Double?
  public let value: Double?
  public let volume: Double?
}

extension APICMCSymbolHistories: CMCSymbolHistoriesEntity {}
