import SwiftUI

public struct CandleChart: View {
  public var chartData = CandleChartData()

  @EnvironmentObject var style: ChartStyle

  public var chartProperties = CandleChartProperties()

  public var body: some View {
    CandleChartRow(chartData: chartData, style: style, properties: chartProperties)
  }

  public init() {}
}
