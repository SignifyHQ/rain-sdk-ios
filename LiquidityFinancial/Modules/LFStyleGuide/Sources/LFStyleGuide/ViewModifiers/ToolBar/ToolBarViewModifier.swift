import SwiftUI
import LFUtilities

// MARK: - View Extension
extension View {
  public func defaultToolBar(
    icon: ToolBarIcon? = nil,
    navigationTitle: String? = nil,
    onDismiss: (() -> Void)? = nil,
    openSupportScreen: (() -> Void)? = nil
  ) -> some View {
    modifier(
      ToolBarModifier(
        icon: icon,
        navigationTitle: navigationTitle ?? "",
        onDismiss: onDismiss,
            openSupportScreen: openSupportScreen
      )
    )
  }
}

// MARK: - Type
public enum ToolBarIcon {
  case xMark
  case support
  case both
}

// MARK: - View Modifier
private struct ToolBarModifier: ViewModifier {
  @Environment(\.dismiss) private var dismiss
  let icon: ToolBarIcon?
  let navigationTitle: String
  let onDismiss: (() -> Void)?
  let openSupportScreen: (() -> Void)?

  init(
    icon: ToolBarIcon? = nil,
    navigationTitle: String = "",
    onDismiss: (() -> Void)? = nil,
    openSupportScreen: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.navigationTitle = navigationTitle
    self.onDismiss = onDismiss
    self.openSupportScreen = openSupportScreen
  }
  
  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if icon == .xMark || icon == .both {
            Button {
              onDismiss?()
              dismiss() // Default dismiss of sheetView
            } label: {
              CircleButton(style: .xmark)
            }
          }
        }
        ToolbarItem(placement: .principal) {
          Text(navigationTitle)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          if icon == .support || icon == .both {
            Button {
              openSupportScreen?()
            } label: {
              GenImages.CommonImages.icChat.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
            }
          }
        }
      }
  }
}
