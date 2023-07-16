import SwiftUI
import LFUtilities

// MARK: - PrimaryFieldStyle
struct PrimaryFieldStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
  }
}

public extension View {
  func primaryFieldStyle() -> some View {
    modifier(PrimaryFieldStyle())
  }
}
