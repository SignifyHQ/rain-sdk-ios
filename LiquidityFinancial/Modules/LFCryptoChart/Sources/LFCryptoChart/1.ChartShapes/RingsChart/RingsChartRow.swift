import SwiftUI

public struct RingsChartRow: View {
  var width: CGFloat
  var spacing: CGFloat

  @EnvironmentObject var chartValue: ChartValue
  @ObservedObject var chartData: ChartData
  @State private var touchRadius: CGFloat = -1.0

  var style: ChartStyle

  public var body: some View {
    GeometryReader { geometry in

      ZStack {
        // FIXME: Why is background circle offset strangely when frame isn't specified? See Preview below. Related to the .animation somehow ????
        Circle()
          .fill(RadialGradient(gradient: style.backgroundColor.gradient, center: .center, startRadius: min(geometry.size.width, geometry.size.height) / 2.0, endRadius: 1.0))

        ForEach(0 ..< chartData.data.count, id: \.self) { index in

          let scaleUp = isRingScaled(size: geometry.size, touchRadius: touchRadius, index: index)
          let scaledWidth = scaleUp ? width * 2.0 : width

          let normalPadding = (width + spacing) * CGFloat(index)
          let scaledDiff = (scaledWidth - width) / 2.0
          let padding = min(normalPadding - scaledDiff,
                            min(geometry.size.width, geometry.size.height) / 2.0 - width
                            // make sure it doesn't get to crazy value
          )

          Ring(
            ringWidth: scaledWidth,
            percent: chartData.points[index],
            foregroundColor: style.foregroundColor.rotate(for: index),
            touchLocation: touchRadius
          )
          .zIndex(scaleUp ? 1 : 0)
          // make sure zoomed one is on top
          .padding(padding)
          .animation(
            Animation.easeIn(duration: 0.5),
            value: UUID()
          )
        }
      }

      .gesture(DragGesture()
        .onChanged { value in
          let frame = geometry.frame(in: .local)
          let radius = min(frame.width, frame.height) / 2.0
          let deltaX = value.location.x - frame.midX
          let deltaY = value.location.y - frame.midY
          touchRadius = sqrt(deltaX * deltaX + deltaY * deltaY) // Pythagorean equation

          if let currentValue = getCurrentValue(maxRadius: radius) {
            chartValue.currentValue = currentValue
            chartValue.interactionInProgress = true
          }
        }
        .onEnded { _ in
          chartValue.interactionInProgress = false
          touchRadius = -1
        }
      )
    }
  }

  /// should we scale up the touched ring?
  /// - Parameters:
  ///   - size: size of the view
  ///   - touchRadius: distance from center where touched
  ///   - index: which ring is being drawn
  /// - Returns: size to scale up or just scale of 1 if not scaled up
  func isRingScaled(size: CGSize, touchRadius: CGFloat, index: Int) -> Bool {
    let radius = min(size.width, size.height) / 2.0
    return index == touchedCircleIndex(maxRadius: radius)
  }

  /// Find which circle has been touched
  /// - Parameter maxRadius: radius of overall view circle
  /// - Returns: which circle index was touched, if found. 0 = outer, 1 = next one in, etc.
  func touchedCircleIndex(maxRadius: CGFloat) -> Int? {
    if chartData.data.isEmpty { return nil } // no data

    // Pretend actual circle goes ½ the inter-ring spacing out, so that a touch
    // is registered on either side of each ring
    let radialDistanceFromEdge = (maxRadius + spacing / 2) - touchRadius
    guard radialDistanceFromEdge >= 0 else { return nil } // touched outside of ring

    let touchIndex = Int(floor(radialDistanceFromEdge / (width + spacing)))

    if touchIndex >= chartData.data.count { return nil } // too far from outside, no ring

    return touchIndex
  }

  /// Description
  /// - Parameter maxRadius: radius of overall view circle
  /// - Returns: percentage value of the touched circle, based on `touchRadius` if found
  func getCurrentValue(maxRadius: CGFloat) -> Double? {
    guard let index = touchedCircleIndex(maxRadius: maxRadius) else { return nil }
    return chartData.points[index]
  }
}

struct RingsChartRow_Previews: PreviewProvider {
  static var previews: some View {
    let multiStyle = ChartStyle(backgroundColor: ColorGradient(Color.black.opacity(0.05), Color.white),
                                foregroundColor:
                                [ColorGradient(.purple, .blue),
                                 ColorGradient(.orange, .red),
                                 ColorGradient(.green, .yellow)])

    return RingsChartRow(width: 20.0, spacing: 10.0, chartData: ChartData([25, 50, 75, 100, 125]), style: multiStyle)

      // and why does this not get centered when frame isn't specified?
      .frame(width: 300, height: 400)
  }
}
