import SwiftUI
import LFUtilities

// MARK: - View Extension
extension View {
  public func defaultToolBar(
    icon: ToolBarIcon? = nil,
    navigationTitle: String? = nil,
    onDismiss: (() -> Void)? = nil,
    openSupportScreen: (() -> Void)? = nil,
    edgeInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
  ) -> some View {
    modifier(
      ToolBarModifier(
        icon: icon,
        navigationTitle: navigationTitle ?? "",
        onDismiss: onDismiss,
        openSupportScreen: openSupportScreen,
        edgeInsets: edgeInsets
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
  let edgeInsets: EdgeInsets
  
  init(
    icon: ToolBarIcon? = nil,
    navigationTitle: String = "",
    onDismiss: (() -> Void)? = nil,
    openSupportScreen: (() -> Void)? = nil,
    edgeInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
  ) {
    self.icon = icon
    self.navigationTitle = navigationTitle
    self.onDismiss = onDismiss
    self.openSupportScreen = openSupportScreen
    self.edgeInsets = edgeInsets
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
                .padding(edgeInsets)
            }
          }
        }
        ToolbarItem(placement: .principal) {
          Text(navigationTitle)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .padding(edgeInsets)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          if icon == .support || icon == .both {
            Button {
              openSupportScreen?()
            } label: {
              GenImages.CommonImages.icChat.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
                .padding(edgeInsets)
            }
          }
        }
      }
  }
}
