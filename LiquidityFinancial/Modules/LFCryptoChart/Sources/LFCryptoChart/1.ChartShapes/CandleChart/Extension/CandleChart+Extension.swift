import Foundation
import SwiftUI
import CryptoChartData

public extension CandleChart {
  func setLineWidth(width: CGFloat) -> Self {
    chartProperties.lineWidth = width
    return self
  }

  func setBodyWidth(width: CGFloat) -> Self {
    chartProperties.bodyWidth = width
    return self
  }

  func setBackground(colorGradient: ColorGradient) -> Self {
    chartProperties.backgroundGradient = colorGradient
    return self
  }

  func setNegative(colorGradient: ColorGradient) -> Self {
    chartProperties.negativeGradient = colorGradient
    return self
  }

  func setPositive(colorGradient: ColorGradient) -> Self {
    chartProperties.positiveGradient = colorGradient
    return self
  }

  func data(candleDatas: [CandleData]) -> Self {
    chartData.data = candleDatas
    return self
  }

  func rangeY(rangeY: ClosedRange<Double>?) -> Self {
    chartData.rangeY = rangeY
    return self
  }

  func rangeX(rangeX: ClosedRange<Double>?) -> Self {
    chartData.rangeX = rangeX
    return self
  }

  func setGridColor(to color: Color) -> Self {
    chartProperties.gridColor = color
    return self
  }

  func setShowGridXLines(to showGridXLines: Bool) -> Self {
    chartProperties.showGridXLines = showGridXLines
    return self
  }

  func setShowGridYLines(to showGridYLines: Bool) -> Self {
    chartProperties.showGridYLines = showGridYLines
    return self
  }

  func gridXIndexes(_ indexes: [(String, Double)]) -> Self {
    chartData.gridXIndexes = indexes
    return self
  }

  func gridYIndexes(_ indexes: [(String, Double)]) -> Self {
    chartData.gridYIndexes = indexes
    return self
  }
}
