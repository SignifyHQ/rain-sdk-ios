import SwiftUI

extension Double {
  func toRadians() -> Double {
    self * Double.pi / 180
  }

  func toCGFloat() -> CGFloat {
    CGFloat(self)
  }
}

struct RingShape: Shape {
  /// Helper function to convert percent values to angles in degrees
  /// - Parameters:
  ///   - percent: percent, greater than 100 is OK
  ///   - startAngle: angle to add after converting
  /// - Returns: angle in degrees
  static func percentToAngle(percent: Double, startAngle: Double) -> Double {
    (percent / 100 * 360) + startAngle
  }

  private var percent: Double
  private var startAngle: Double
  private let drawnClockwise: Bool

  // This allows animations to run smoothly for percent values
  var animatableData: Double {
    get {
      percent
    }
    set {
      percent = newValue
    }
  }

  init(percent: Double = 100, startAngle: Double = -90, drawnClockwise: Bool = false) {
    self.percent = percent
    self.startAngle = startAngle
    self.drawnClockwise = drawnClockwise
  }

  /// This draws a simple arc from the start angle to the end angle
  ///
  /// - Parameter rect: The frame of reference for describing this shape.
  /// - Returns: A path that describes this shape.
  func path(in rect: CGRect) -> Path {
    let width = rect.width
    let height = rect.height
    let radius = min(width, height) / 2
    let center = CGPoint(x: width / 2, y: height / 2)
    let endAngle = Angle(degrees: RingShape.percentToAngle(percent: percent, startAngle: startAngle))
    return Path { path in
      path.addArc(center: center, radius: radius, startAngle: Angle(degrees: startAngle), endAngle: endAngle, clockwise: drawnClockwise)
    }
  }
}

struct Ring: View {
  private static let ShadowColor: Color = .black.opacity(0.2)
  private static let ShadowRadius: CGFloat = 5
  private static let ShadowOffsetMultiplier: CGFloat = ShadowRadius + 2

  private let ringWidth: CGFloat
  private let percent: Double
  private let foregroundColor: ColorGradient
  private let startAngle: Double = -90

  private let touchLocation: CGFloat

  private var gradientStartAngle: Double {
    percent >= 100 ? relativePercentageAngle - 360 : startAngle
  }

  private var absolutePercentageAngle: Double {
    RingShape.percentToAngle(percent: percent, startAngle: 0)
  }

  private var relativePercentageAngle: Double {
    // Take into account the startAngle
    absolutePercentageAngle + startAngle
  }

  private var lastGradientColor: Color {
    foregroundColor.endColor
  }

  private var ringGradient: AngularGradient {
    AngularGradient(
      gradient: foregroundColor.gradient,
      center: .center,
      startAngle: Angle(degrees: gradientStartAngle),
      endAngle: Angle(degrees: relativePercentageAngle)
    )
  }

  init(ringWidth: CGFloat, percent: Double, foregroundColor: ColorGradient, touchLocation: CGFloat) {
    self.ringWidth = ringWidth
    self.percent = percent
    self.foregroundColor = foregroundColor
    self.touchLocation = touchLocation
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Background for the ring. Use the final color with reduced opacity
        RingShape()
          .stroke(style: StrokeStyle(lineWidth: ringWidth))
          .fill(lastGradientColor.opacity(0.142857))
        // Foreground
        RingShape(percent: percent, startAngle: startAngle)
          .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
          .fill(ringGradient)
        // End of ring with drop shadow
        if getShowShadow(frame: geometry.size) {
          Circle()
            .fill(lastGradientColor)
            .frame(width: ringWidth, height: ringWidth, alignment: .center)
            .offset(x: getEndCircleLocation(frame: geometry.size).0,
                    y: getEndCircleLocation(frame: geometry.size).1)
            .shadow(color: Ring.ShadowColor,
                    radius: Ring.ShadowRadius,
                    x: getEndCircleShadowOffset().0,
                    y: getEndCircleShadowOffset().1)
        }
      }
    }
    // Padding to ensure that the entire ring fits within the view size allocated
    .padding(ringWidth / 2)
  }

  private func getEndCircleLocation(frame: CGSize) -> (CGFloat, CGFloat) {
    // Get angle of the end circle with respect to the start angle
    let angleOfEndInRadians: Double = relativePercentageAngle.toRadians()
    let offsetRadius = min(frame.width, frame.height) / 2
    return (offsetRadius * cos(angleOfEndInRadians).toCGFloat(), offsetRadius * sin(angleOfEndInRadians).toCGFloat())
  }

  private func getEndCircleShadowOffset() -> (CGFloat, CGFloat) {
    let angleForOffset = absolutePercentageAngle + (startAngle + 90)
    let angleForOffsetInRadians = angleForOffset.toRadians()
    let relativeXOffset = cos(angleForOffsetInRadians)
    let relativeYOffset = sin(angleForOffsetInRadians)
    let xOffset = relativeXOffset.toCGFloat() * Ring.ShadowOffsetMultiplier
    let yOffset = relativeYOffset.toCGFloat() * Ring.ShadowOffsetMultiplier
    return (xOffset, yOffset)
  }

  private func getShowShadow(frame: CGSize) -> Bool {
    if percent >= 100 {
      return true
    }
    let circleRadius = min(frame.width, frame.height) / 2
    let remainingAngleInRadians = (360 - absolutePercentageAngle).toRadians().toCGFloat()

    return circleRadius * remainingAngleInRadians <= ringWidth
  }
}

struct Ring_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Ring(
        ringWidth: 50, percent: 5,
        foregroundColor: ColorGradient(.green, .blue), touchLocation: -1.0
      )
      .frame(width: 200, height: 200)

      Ring(
        ringWidth: 20, percent: 110,
        foregroundColor: ColorGradient(.red, .blue), touchLocation: -1.0
      )
      .frame(width: 200, height: 200)
    }
  }
}
