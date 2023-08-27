import SwiftUI
import LFStyleGuide

public struct Line: View {
  @EnvironmentObject var chartValue: ChartValue
  
  @ObservedObject var chartData: ChartData
  @ObservedObject var chartProperties: LineChartProperties
  
  @State private var showIndicator: Bool = false
  @State private var touchLocation: CGPoint = .zero
  @State private var didCellAppear: Bool = false
  @State private var selectedPoint: (Double, Double)?
  
  var style: ChartStyle
  
  var path: Path {
    Path.quadCurvedPathWithPoints(
      points: chartData.normalisedPoints,
      step: CGPoint(x: 1.0, y: 1.0)
    )
  }
  
  public init(
    chartData: ChartData,
    style: ChartStyle,
    chartProperties: LineChartProperties
  ) {
    self.chartData = chartData
    self.style = style
    self.chartProperties = chartProperties
  }
  
  public var body: some View {
    GeometryReader { geometry in
      HStack {
        ZStack {
          if didCellAppear, let backgroundColor = chartProperties.backgroundGradient {
            LineBackgroundShapeView(
              chartData: chartData,
              geometry: geometry,
              backgroundColor: backgroundColor
            )
          }
          lineShapeView(geometry: geometry)
          gridXLineView
          if showIndicator, let selectedPoint = selectedPoint {
            VStack(alignment: .leading, spacing: 8) {
              Spacer()
                .frame(height: 10)
              ChartGridXShape(xOffset: selectedPoint.0)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .stroke(chartProperties.gridColor)
                .toStandardCoordinateSystem()
            }
            MarkerShape(data: [selectedPoint])
              .fill(
                chartProperties.indicatorColor,
                strokeBorder: chartProperties.indicatorBorderColor,
                lineWidth: chartProperties.lineWidth
              )
              .shadow(
                color: ChartColors.legendColor, radius: 6, x: 0, y: 0
              )
              .toStandardCoordinateSystem()
          }
        }
        gridYLineView
      }
      .background(Colors.background.swiftUIColor)
      .onAppear {
        didCellAppear = true
      }
      .onDisappear {
        didCellAppear = false
      }
      .gesture(
        chartProperties.highlightValueEnable ?
        DragGesture()
          .onChanged { value in
            touchLocation = value.location
            showIndicator = true
            getClosestDataPoint(geometry: geometry, touchLocation: value.location)
          }
          .onEnded { value in
            touchLocation = .zero
          }
        : nil
      )
    }
  }
}

// MARK: - View Components
private extension Line {
  @ViewBuilder var gridXLineView: some View {
    if chartProperties.showGridXLines {
      GeometryReader { metrics in
        ForEach(chartData.gridXIndexes, id: \.1) { text, xOffset in
          VStack(alignment: .leading, spacing: 8) {
            Text(text)
              .font(Fonts.regular.swiftUIFont(size: 10))
              .foregroundColor(Colors.label.swiftUIColor)
              .opacity(0.5)
              .offset(
                CGSize(
                  width: xOffset * metrics.size.width - 40,
                  height: 0
                )
              )
            
            ChartGridXShape(xOffset: xOffset)
              .stroke(chartProperties.gridColor)
              .toStandardCoordinateSystem()
          }
        }
      }
    }
  }
  
  @ViewBuilder var gridYLineView: some View {
    if chartProperties.showGridYLines {
      GeometryReader { metrics in
        ForEach(chartData.gridYIndexes, id: \.1) { text, yOffset in
          VStack(alignment: .leading, spacing: 8) {
            Text(text)
              .font(Fonts.regular.swiftUIFont(size: 10))
              .foregroundColor(Colors.label.swiftUIColor)
              .opacity(0.5)
              .offset(
                CGSize(
                  width: 0,
                  height: (1.0 - yOffset) * metrics.size.height
                )
              )
          }
        }
      }
      .frame(maxWidth: chartProperties.gridYBaseWidth)
    }
  }
  
  func lineShapeView(geometry: GeometryProxy) -> some View {
    LineShapeView(
      chartData: chartData,
      chartProperties: chartProperties,
      geometry: geometry,
      style: style,
      trimTo: didCellAppear ? 1.0 : 0.0
    )
    .animation(
      Animation.easeIn(duration: 0.75),
      value: UUID()
    )
  }
}

// MARK: - Private functions
extension Line {
  /// Calculate point closest to where the user touched
  /// - Parameter touchLocation: location in view where touched
  /// - Returns: `CGPoint` of data point on chart
  private func getClosestPointOnPath(geometry: GeometryProxy, touchLocation: CGPoint) -> CGPoint {
    let geometryWidth = geometry.frame(in: .local).width
    let normalisedTouchLocationX = (touchLocation.x / geometryWidth) * CGFloat(chartData.normalisedPoints.count - 1)
    let closest = path.point(to: normalisedTouchLocationX)
    var denormClosest = closest.denormalize(with: geometry)
    denormClosest.x /= CGFloat(chartData.normalisedPoints.count - 1)
    denormClosest.y /= CGFloat(chartData.normalisedYRange)
    return denormClosest
  }
  
  //	/// Figure out where closest touch point was
  //	/// - Parameter point: location of data point on graph, near touch location
  private func getClosestDataPoint(geometry: GeometryProxy, touchLocation: CGPoint) {
    let geometryWidth = geometry.frame(in: .local).width
    let index = Int(round((touchLocation.x / geometryWidth) * CGFloat(chartData.points.count - 1)))
    guard index >= 0, index < chartData.data.count else {
      return
    }
    chartValue.index = index
    chartValue.currentValue = chartData.points[index]
    selectedPoint = (
      chartData.normalisedValues[index],
      chartData.normalisedPoints[index]
    )
  }
}
