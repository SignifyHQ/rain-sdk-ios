import SwiftUI

struct CandleChartCellShape: Shape, Animatable {
  var cornerRadius: CGFloat = 0.0
  var yMin: Double
  var yMax: Double
  var width: Double = 4.0

  func path(in rect: CGRect) -> Path {
    let yMinOffset = rect.height * (1.0 - CGFloat(yMin))
    let yMaxOffset = rect.height * (1.0 - CGFloat(yMax))
    let xMinOffset = rect.width / 2 - width / 2
    let xMaxOffset = xMinOffset + width
    var path = Path()
    path.move(to: CGPoint(x: xMinOffset, y: yMinOffset))
    path.addLine(to: CGPoint(x: xMinOffset, y: yMaxOffset + cornerRadius))
    path.addArc(
      center: CGPoint(
        x: xMinOffset + cornerRadius,
        y: yMaxOffset + cornerRadius
      ),
      radius: cornerRadius,
      startAngle: Angle(radians: Double.pi),
      endAngle: Angle(radians: -Double.pi / 2),
      clockwise: false
    )
    path.addLine(
      to: CGPoint(
        x: xMaxOffset - cornerRadius,
        y: yMaxOffset
      )
    )
    path.addArc(
      center: CGPoint(
        x: xMaxOffset - cornerRadius,
        y: yMaxOffset + cornerRadius
      ),
      radius: cornerRadius,
      startAngle: Angle(radians: -Double.pi / 2),
      endAngle: Angle(radians: 0),
      clockwise: false
    )
    path.addLine(to: CGPoint(x: xMaxOffset, y: yMinOffset))
    path.closeSubpath()

    return path
  }
}
