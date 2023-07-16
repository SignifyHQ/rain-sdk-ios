import SwiftUI

// MARK: - View Extension
public extension View {
  func placeholderStyle(showPlaceholder: Bool, placeholder: String) -> some View {
    modifier(
      PlaceholderStyle(showPlaceHolder: showPlaceholder, placeholder: placeholder)
    )
  }
}
