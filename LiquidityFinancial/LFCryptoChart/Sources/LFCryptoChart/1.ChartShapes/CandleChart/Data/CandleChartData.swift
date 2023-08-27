import SwiftUI
import CryptoChartData

/// An observable wrapper for an array of data for use in any chart
public class CandleChartData: ObservableObject {
  @Published public var data: [CandleData] = []
  public var rangeY: ClosedRange<Double>?
  public var rangeX: ClosedRange<Double>?
  public var gridXIndexes = [(String, Double)]()
  public var gridYIndexes = [(String, Double)]()

  var normalisedData: [CandleData] {
    let absolutePoints = data.map { abs($0.high) }
    let absoluteXValues = data.map { abs($0.xValue) }
    var maxPoint = absolutePoints.max()
    let maxX = absoluteXValues.max()
    if let rangeY = rangeY {
      maxPoint = Double(rangeY.overreach)
      return data.map {
        var newData = ($0 - rangeY.lowerBound) / (maxPoint ?? 1.0)
        newData.xValue = newData.xValue / (maxX ?? 1.0)
        return newData
      }
    }

    return data.map {
      var newData = $0 / (maxPoint ?? 1.0)
      newData.xValue = newData.xValue / (maxX ?? 1.0)
      return newData
    }
  }

  /// Initialize with data array
  /// - Parameter data: Array of `Double`
  public init(_ data: [CandleData], rangeY: ClosedRange<FloatLiteralType>? = nil) {
    self.data = data
    self.rangeY = rangeY
  }

  public init() {
    data = []
  }
}
