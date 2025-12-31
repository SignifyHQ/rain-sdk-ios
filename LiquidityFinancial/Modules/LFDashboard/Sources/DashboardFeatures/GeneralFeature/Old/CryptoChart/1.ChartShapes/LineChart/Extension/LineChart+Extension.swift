import SwiftUI

public extension LineChart {
  func setLineWidth(width: CGFloat) -> LineChart {
    chartProperties.lineWidth = width
    return self
  }

  func setBackground(colorGradient: ColorGradient) -> LineChart {
    chartProperties.backgroundGradient = colorGradient
    return self
  }

  func showChartMarks(_ show: Bool, with color: ColorGradient? = nil) -> LineChart {
    chartProperties.showChartMarks = show
    chartProperties.customChartMarksColors = color
    return self
  }

  func showGridLines(_ show: Bool, with color: Color) -> LineChart {
    chartProperties.showGridXLines = show
    chartProperties.gridColor = color
    return self
  }

  func setLineStyle(to style: LineStyle) -> LineChart {
    chartProperties.lineStyle = style
    return self
  }

  func setIndicatorColor(to color: Color) -> LineChart {
    chartProperties.indicatorColor = color
    return self
  }

  func setIndicatorBorderColor(to color: Color) -> LineChart {
    chartProperties.indicatorBorderColor = color
    return self
  }

  func setHighlightValueEnable(to enable: Bool) -> LineChart {
    chartProperties.highlightValueEnable = enable
    return self
  }

  func setShowGridXLines(to showGridXLines: Bool) -> LineChart {
    chartProperties.showGridXLines = showGridXLines
    return self
  }

  func setShowGridYLines(to showGridYLines: Bool) -> LineChart {
    chartProperties.showGridYLines = showGridYLines
    return self
  }

  func setGridColor(to color: Color) -> LineChart {
    chartProperties.gridColor = color
    return self
  }
}
