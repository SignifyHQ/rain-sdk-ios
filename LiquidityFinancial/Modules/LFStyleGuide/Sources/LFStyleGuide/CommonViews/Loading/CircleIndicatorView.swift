import SwiftUI

public struct CircleIndicatorView: View {
  @State private var isLoading = false
  let size: CGFloat
  
  public init(size: CGFloat = 20) {
    self.size = size
  }
  
  public var body: some View {
    Circle()
      .stroke(Colors.primary.swiftUIColor.opacity(0.1), lineWidth: 5)
      .frame(width: size, height: size)
      .overlay(
        Circle()
          .trim(from: 0, to: 0.7)
          .stroke(
            LinearGradient(
              gradient: Gradient(colors: [Colors.primary.swiftUIColor, Colors.primary.swiftUIColor.opacity(0)]),
              startPoint: .leading,
              endPoint: .trailing
            ),
            style: StrokeStyle(
              lineWidth: 4,
              lineCap: .round
            )
          )
          .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
          .animation(
            .linear(duration: 1.5).repeatForever(autoreverses: false),
            value: isLoading
          )
      )
      .onAppear {
        isLoading = true
      }
      .onDisappear {
        isLoading = false
      }
  }
}
