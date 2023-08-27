import SwiftUI

struct ChartGridXShape: Shape {
  var xOffset: Double

  func path(in rect: CGRect) -> Path {
    let path = Path.drawGridXLine(
      xOffset: xOffset,
      in: rect
    )
    return path
  }
}
