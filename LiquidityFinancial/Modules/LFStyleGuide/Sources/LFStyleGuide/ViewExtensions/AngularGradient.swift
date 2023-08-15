import SwiftUI

public extension AngularGradient {
  static func primary(colors: [Color]) -> Self {
    .init(
      gradient: .init(colors: colors),
      center: .center,
      startAngle: .degrees(-180),
      endAngle: .degrees(180)
    )
  }
}
