import SwiftUI
import CryptoChartData

public struct CandleChartCell: View {
  var index: Int = 0
  var touchLocation: CGFloat

  var negativeColor: ColorGradient
  var positiveColor: ColorGradient

  var high: Double = 0.9
  var low: Double = 0.4
  var open: Double = 0.4
  var close: Double = 0.6

  var lineWidth: Double = 1
  var bodyWidth: Double = 4

  @State private var didCellAppear: Bool = false

  var yMin: Double {
    min(low, high)
  }

  var yMax: Double {
    max(low, high)
  }

  var yMinBody: Double {
    min(open, close)
  }

  var yMaxBody: Double {
    max(open, close)
  }

  var color: ColorGradient {
    open < close ? positiveColor : negativeColor
  }

  public init(data: CandleData,
              index: Int = 0,
              negativeColor: ColorGradient,
              positiveColor: ColorGradient,
              touchLocation: CGFloat,
              lineWidth: CGFloat = 1.0,
              bodyWidth: CGFloat = 4.0)
  {
    low = data.low
    high = data.high
    open = data.open
    close = data.close

    self.lineWidth = lineWidth
    self.bodyWidth = bodyWidth

    self.index = index
    self.negativeColor = negativeColor
    self.positiveColor = positiveColor
    self.touchLocation = touchLocation
  }

  public var body: some View {
    ZStack(alignment: .center) {
      CandleChartCellShape(
        yMin: yMin,
        yMax: didCellAppear ? yMax : yMin,
        width: lineWidth
      )
      .fill(color.linearGradient(from: .bottom, to: .top))

      CandleChartCellShape(
        yMin: yMinBody,
        yMax: didCellAppear ? yMaxBody : yMinBody,
        width: bodyWidth
      )
      .fill(color.linearGradient(from: .bottom, to: .top))
    }
    .onAppear {
      didCellAppear = true
    }
    .onDisappear {
      didCellAppear = false
    }
    .transition(.slide)
    .animation(
      Animation.spring()
        .delay(
          touchLocation < 0 || !didCellAppear ? Double(index) * 0.04 : 0
        ),
      value: UUID()
    )
  }
}

struct CandleChartCell_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Group {
        CandleChartCell(
          data: CandleData(
            low: 0.3, high: 0.6, open: 0.4, close: 0.5, xValue: 1
          ),
          negativeColor: ColorGradient.greenRed,
          positiveColor: ColorGradient.redBlack,
          touchLocation: CGFloat()
        )
      }
    }
  }
}
