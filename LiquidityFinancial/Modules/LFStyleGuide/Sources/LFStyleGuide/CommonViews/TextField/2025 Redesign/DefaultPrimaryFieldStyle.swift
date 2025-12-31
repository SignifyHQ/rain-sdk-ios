import SwiftUI

// MARK: - PrimaryFieldStyle

public struct DefaultPrimaryFieldStyle: ViewModifier {
  var font: SwiftUI.Font
  var color: Color
  
  init(
    font: SwiftUI.Font,
    color: Color
  ) {
    self.font = font
    self.color = color
  }
  
  public func body(content: Content) -> some View {
    content
      .foregroundColor(color)
      .font(font)
  }
}

public extension View {
  func defaultPrimaryFieldStyle(
    font: SwiftUI.Font = Fonts.regular.swiftUIFont(size: 16),
    color: Color = Colors.label.swiftUIColor
  ) -> some View {
    modifier(DefaultPrimaryFieldStyle(font: font, color: color))
  }
}
