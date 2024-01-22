import SwiftUI
import LFStyleGuide

public struct CandleChartRow: View {
  @EnvironmentObject var chartValue: ChartValue
  @ObservedObject var chartData: CandleChartData
  @State private var touchLocation: CGFloat = -1.0
  
  var style: ChartStyle
  var properties: CandleChartProperties
  
  public var body: some View {
    GeometryReader { geometry in
      HStack {
        ZStack {
          HStack(alignment: .bottom, spacing: 4) {
            ForEach(0 ..< chartData.data.count, id: \.self) { index in
              ZStack {
                if chartValue.index == index {
                  VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                      .frame(height: 10)
                    ChartGridXShape(xOffset: 0)
                      .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                      .stroke(properties.gridColor)
                      .toStandardCoordinateSystem()
                  }
                }
                CandleChartCell(
                  data: chartData.normalisedData[index],
                  index: index,
                  negativeColor: properties.negativeGradient ?? .greenRed,
                  positiveColor: properties.positiveGradient ?? .orangeBright,
                  touchLocation: touchLocation,
                  lineWidth: properties.lineWidth,
                  bodyWidth: properties.bodyWidth
                )
              }
            }
          }
          .frame(maxHeight: geometry.size.height)
          .background(Colors.background.swiftUIColor)
          .gesture(
            DragGesture()
              .onChanged { value in
                let width = geometry.frame(in: .local).width - properties.gridYBaseWidth
                touchLocation = value.location.x / width
                if let index = getCurrentIndex(width: width) {
                  chartValue.index = index
                  chartValue.interactionInProgress = true
                }
              }
              .onEnded { _ in
                chartValue.interactionInProgress = false
              }
          )
          if properties.showGridXLines {
            GeometryReader { metrics in
              ForEach(chartData.gridXIndexes, id: \.1) { text, xOffset in
                VStack(alignment: .leading, spacing: 8) {
                  Text(text)
                    .font(Fonts.regular.swiftUIFont(size: 10))
                    .foregroundColor(Colors.label.swiftUIColor)
                    .opacity(0.5)
                    .frame(width: 100)
                    .offset(
                      CGSize(
                        width: xOffset * metrics.size.width - 50,
                        height: 0
                      )
                    )
                  ChartGridXShape(xOffset: xOffset)
                    .stroke(properties.gridColor)
                    .toStandardCoordinateSystem()
                }
              }
            }
          }
        }
        
        if properties.showGridYLines {
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
          .frame(maxWidth: properties.gridYBaseWidth)
        }
      }
    }
  }
  
  func getScaleSize(touchLocation: CGFloat, index: Int) -> CGSize {
    if touchLocation > CGFloat(index) / CGFloat(chartData.data.count),
       touchLocation < CGFloat(index + 1) / CGFloat(chartData.data.count)
    {
      return CGSize(width: 1.4, height: 1.1)
    }
    return CGSize(width: 1, height: 1)
  }
  
  func getCurrentIndex(width: CGFloat) -> Int? {
    guard !chartData.data.isEmpty else {
      return nil
    }
    let count = chartData.data.count
    let x = touchLocation * width
    var index = Int(
      floor(
        x / (width / CGFloat(count))
      )
    )
    index = max(0, min(count - 1, index))
    return index
  }
}
