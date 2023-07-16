import SwiftUI
import LFUtilities

// MARK: - PlaceholderStyle
struct PlaceholderStyle: ViewModifier {
  var showPlaceHolder: Bool
  var placeholder: String
  
  func body(content: Content) -> some View {
    ZStack(alignment: .leading) {
      if showPlaceHolder {
        Text(placeholder)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.25))
      }
      content
    }
  }
}

// MARK: - View Extension
public extension View {
  func placeholderStyle(showPlaceholder: Bool, placeholder: String) -> some View {
    modifier(
      PlaceholderStyle(showPlaceHolder: showPlaceholder, placeholder: placeholder)
    )
  }
}
