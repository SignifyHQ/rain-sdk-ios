import SwiftUI

public struct DefaultPlaceholderStyle: ViewModifier {
  let showPlaceHolder: Bool
  let placeholder: String
  let font: SwiftUI.Font
  let color: Color
  
  public init(
    showPlaceHolder: Bool,
    placeholder: String,
    font: SwiftUI.Font = Fonts.regular.swiftUIFont(size: 16),
    color: Color = Colors.textSecondary.swiftUIColor
  ) {
    self.showPlaceHolder = showPlaceHolder
    self.placeholder = placeholder
    self.font = font
    self.color = color
  }

  public func body(content: Content) -> some View {
    ZStack(alignment: .leading) {
      if showPlaceHolder {
        Text(placeholder)
          .font(font)
          .foregroundColor(color)
      }
      
      content
    }
  }
}
