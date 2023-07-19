import SwiftUI

public struct GradientIndicatorView: View {
  @Binding var isVisible: Bool
  @State private var rotation: Double = 0

  let colors: [Color]
  let lineWidth: CGFloat
  let gradientColors: Gradient
  let conic: AngularGradient
  private let animation = Animation
    .linear(duration: 1.5)
    .repeatForever(autoreverses: false)

  public init(isVisible: Binding<Bool>, colors: [Color], lineWidth: CGFloat) {
    _isVisible = isVisible
    self.colors = colors
    self.lineWidth = lineWidth
    gradientColors = Gradient(colors: colors)
    conic = AngularGradient(
      gradient: gradientColors,
      center: .center,
      startAngle: .zero,
      endAngle: .degrees(360)
    )
  }
  
  public var body: some View {
    ZStack {
      if isVisible {
        indicator
      }
    }
  }
}

// MARK: View Components
private extension GradientIndicatorView {
  var indicator: some View {
    ZStack {
      Circle()
        .stroke(colors.first ?? .white, lineWidth: lineWidth)
      Circle()
        .trim(from: lineWidth / 500, to: 1 - lineWidth / 100)
        .stroke(conic, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        .rotationEffect(.degrees(rotation))
        .onAppear {
          rotation = 0
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(animation) {
              rotation = 360
            }
          }
        }
    }
  }
}
