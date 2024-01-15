import Foundation
import CryptoChartDomain
import LFUtilities

public struct CandleData {
  public var low: Double
  public var high: Double
  public var open: Double
  public var close: Double
  public var xValue: Double
  
  public var shouldGridLine: Bool = false
  public var gridTitle = ""
  
  public init(low: Double, high: Double, open: Double, close: Double, xValue: Double) {
    self.low = low
    self.high = high
    self.open = open
    self.close = close
    self.xValue = xValue
  }
}

public extension CandleData {
  static func / (left: CandleData, right: CGFloat) -> CandleData {
    CandleData(
      low: left.low / right,
      high: left.high / right,
      open: left.open / right,
      close: left.close / right,
      xValue: left.xValue
    )
  }
  
  static func - (left: CandleData, right: CGFloat) -> CandleData {
    CandleData(
      low: left.low - right,
      high: left.high - right,
      open: left.open - right,
      close: left.close - right,
      xValue: left.xValue
    )
  }
}

public extension Array where Element == CandleData {
  func rangeY(with extendScale: Double = 0.1) -> ClosedRange<FloatLiteralType> {
    guard let first = first else {
      return 0 ... 1
    }
    var minValue: Double = first.low
    var maxValue: Double = first.high
    
    for value in self {
      minValue = Swift.min(minValue, value.low)
      maxValue = Swift.max(maxValue, value.high)
    }
    let duration = (maxValue - minValue) * extendScale
    return (Swift.max(minValue - duration, 0.0)) ... (maxValue + duration)
  }
  
  func rangeX(with extendScale: Double = 0.0) -> ClosedRange<FloatLiteralType> {
    guard let first = first else {
      return 0 ... 1
    }
    var minValue: Double = first.xValue
    var maxValue: Double = first.xValue
    
    for value in self {
      minValue = Swift.min(minValue, value.xValue)
      maxValue = Swift.max(maxValue, value.xValue)
    }
    let duration = (maxValue - minValue) * extendScale
    return (Swift.max(minValue - duration, 0.0)) ... (maxValue + duration)
  }
}

extension Array where Element == HistoricalPriceModel {
  func toCandleDatas() -> [CandleData] {
    var datas = [CandleData]()
    let count = count
    let xOffsets: [Double] = [0.15, 0.5, 0.85]
    let indexes = xOffsets.map { Int($0 * Double(count)) }
    var index = 0
    for model in self {
      guard let open = model.open,
            let close = model.close,
            let high = model.high,
            let low = model.low
      else {
        log.error("Chart HistoricalPriceModel to CandleData: \(self)")
        continue
      }
      let timestampValue = model.timestamp
      ?? model.lastUpdated?.convertTimestampToDouble(dateFormat: LiquidityDateFormatter.iso8601WithTimeZone.rawValue)
      ?? 0
      var data = CandleData(low: low, high: high, open: open, close: close, xValue: timestampValue)
      if indexes.contains(where: { $0 == index }) {
        data.shouldGridLine = true
        let date = Date(timeIntervalSince1970: Double(timestampValue / 1_000))
        data.gridTitle = LiquidityDateFormatter.chartGridDateTime.parseToString(from: date)
      }
      datas.append(data)
      index += 1
    }
    return datas
  }
  
  func getGridXIndexes(option: CryptoFilterOption) -> [(String, Double)] {
    let count = count
    let xOffsets: [Double] = [0.15, 0.5, 0.85]
    return xOffsets.compactMap { offset -> (String, Double)? in
      let index = Int(offset * Double(count))
      guard index >= 0, index < count - 1 else {
        return nil
      }
      let model = self[index]
      let timestampValue = model.timestamp
      ?? model.lastUpdated?.convertTimestampToDouble(dateFormat: LiquidityDateFormatter.iso8601WithTimeZone.rawValue)
      ?? 0
      let date = Date(timeIntervalSince1970: TimeInterval(timestampValue))
      let dateString = LiquidityDateFormatter.chartGridDateTime.parseToString(from: date)
      
      return (
        dateString.parsingDateStringToNewFormat(toDateFormat: option.datetimeFormat) ?? .empty,
        offset
      )
    }
  }
}
