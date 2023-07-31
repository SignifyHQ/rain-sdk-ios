import SwiftUI

// MARK: - PrimaryFieldStyle

public struct PrimaryFieldStyle: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: 16))
  }
}

public extension View {
  func primaryFieldStyle() -> some View {
    modifier(PrimaryFieldStyle())
  }
}
