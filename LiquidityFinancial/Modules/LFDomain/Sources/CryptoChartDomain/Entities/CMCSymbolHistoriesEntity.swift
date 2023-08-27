import Foundation

public protocol CMCSymbolHistoriesEntity {
  var currency: String { get }
  var interval: String { get }
  var timestamp: String? { get }
  var open: Double? { get }
  var close: Double? { get }
  var high: Double? { get }
  var low: Double? { get }
  var value: Double? { get }
  var volume: Double? { get }
}
