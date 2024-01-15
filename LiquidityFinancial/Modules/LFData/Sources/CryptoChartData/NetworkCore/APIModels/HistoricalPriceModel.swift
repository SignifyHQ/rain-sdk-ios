import Foundation
import CryptoChartDomain
import LFUtilities

public struct HistoricalPriceModel: Codable {
  public let currency: String
  public let interval: String?
  public let timestamp: Double?
  public let changePercentage: Double?
  public let timeOpen: String?
  public let timeHigh: String?
  public let timeLow: String?
  public let lastUpdated: String?
  public let open: Double?
  public let close: Double?
  public let high: Double?
  public let low: Double?
  public let value: Double?
  public let volume: Double?
}

public struct HistoricalPriceSocketModel: Codable {
  let data: HistoricalPriceModel?
}

public struct ListHistoricalPriceSocketModel: Codable {
  let data: [HistoricalPriceModel]?
}

// MARK: - Init
public extension HistoricalPriceModel {
  static func generateHistoricalPriceModel(message: String) -> HistoricalPriceModel? {
    let jsonData = Data(message.utf8)
    let decoder = JSONDecoder()
    do {
      let response = try decoder.decode(HistoricalPriceSocketModel.self, from: jsonData)
      return response.data
    } catch {
      do {
        let response = try decoder.decode(ListHistoricalPriceSocketModel.self, from: jsonData)
        return response.data?.first
      } catch {
        return nil
      }
    }
  }
  
  static func generateHistoricalPriceModel(data: Data) -> HistoricalPriceModel? {
    let decoder = JSONDecoder()
    do {
      let response = try decoder.decode(HistoricalPriceSocketModel.self, from: data)
      return response.data
    } catch {
      do {
        let response = try decoder.decode(ListHistoricalPriceSocketModel.self, from: data)
        return response.data?.first
      } catch {
        return nil
      }
    }
  }
}

// MARK: - Static Functions
public extension HistoricalPriceModel {
  static func map(entities: [CMCSymbolHistoriesEntity]) -> [HistoricalPriceModel] {
    entities.map { item in
      map(entity: item)
    }
  }
  
  static func map(entity: CMCSymbolHistoriesEntity) -> HistoricalPriceModel {
    HistoricalPriceModel(
      currency: entity.currency,
      interval: entity.interval,
      timestamp: entity.timestamp?.convertTimestampToDouble(
        dateFormat: LiquidityDateFormatter.iso8601WithTimeZone.rawValue
      ) ?? 0,
      changePercentage: nil,
      timeOpen: nil,
      timeHigh: nil,
      timeLow: nil,
      lastUpdated: nil,
      open: entity.open,
      close: entity.close,
      high: entity.high,
      low: entity.low,
      value: entity.value,
      volume: entity.volume
    )
  }
}
