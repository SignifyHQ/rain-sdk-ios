import SwiftUI

/// A representation of a sheet presentation.
public struct PopupSheet<Content>: View where Content: View {
  @Environment(\.popupCornerRadius)
  private var cornerRadius
  @Environment(\.defaultMinListRowHeight)
  private var rowHeight
  
  @State private var safeAreaInsetsBottom: CGFloat = 0
  
  private let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    VStack(spacing: 0) {
      content()
        .frame(maxWidth: .infinity, minHeight: rowHeight)
      Spacer()
        .frame(height: safeAreaInsetsBottom)
    }
    .background(Colors.background.swiftUIColor)
    .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
    .fixedSize(horizontal: false, vertical: true)
    // Offset to ensure content is clipped and it's pinned properly.
    // Using `ignoresSafeArea` makes the `safeAreaInsetsBottom` to always return 0
    // which means then we would need to manually offset with hardcoded values for
    // devices.
    .offset(y: safeAreaInsetsBottom)
    .readGeometryChange {
      safeAreaInsetsBottom = $0.safeAreaInsets.bottom
    }
  }
}
