import SwiftUI

public struct LineChart: ChartBase {
  @EnvironmentObject var style: ChartStyle

  public var chartData = ChartData()
  public var chartProperties = LineChartProperties()
  
  public init() {}

  public var body: some View {
    Line(
      chartData: chartData,
      style: style,
      chartProperties: chartProperties
    )
  }
}

public extension LineChart {
  func backgroundGradient(_ gradient: ColorGradient) -> Self {
    chartProperties.backgroundGradient = gradient
    return self
  }
  
  func animationId(_ id: Int) -> Self {
    chartProperties.animationId = id
    return self
  }
}
