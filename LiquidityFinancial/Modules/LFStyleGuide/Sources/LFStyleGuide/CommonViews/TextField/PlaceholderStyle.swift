import SwiftUI

public struct PlaceholderStyle: ViewModifier {
  var showPlaceHolder: Bool
  var placeholder: String
  
  public init(showPlaceHolder: Bool, placeholder: String) {
    self.showPlaceHolder = showPlaceHolder
    self.placeholder = placeholder
  }

  public func body(content: Content) -> some View {
    ZStack(alignment: .leading) {
      if showPlaceHolder {
        Text(placeholder)
          .font(Fonts.Inter.regular.swiftUIFont(size: 16))
          .foregroundColor(Colors.label.swiftUIColor).opacity(0.25)
      }
      content
    }
  }
}

public extension View {
  func placeholderStyle(showPlaceholder: Bool, placeholder: String) -> some View {
    modifier(
      PlaceholderStyle(showPlaceHolder: showPlaceholder, placeholder: placeholder)
    )
  }
}
