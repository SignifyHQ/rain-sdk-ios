import SwiftUI

/// A representation of an alert presentation.
public struct PopupAlert<Content: View>: View {
  @Environment(\.popupPreferredWidth) private var preferredWidth
  @Environment(\.popupCornerRadius) private var cornerRadius
  @Environment(\.popupTextAlignment) private var textAlignment
  @Environment(\.popupDismissAction) private var dismiss
  private let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack(spacing: 0) {
        content()
          .multilineTextAlignment(textAlignment)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding([.horizontal, .bottom], 30)
      .padding(.top, 20)
      .frame(width: preferredWidth)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(cornerRadius, style: .continuous)
      .floatingShadow()

      // Add dismiss button if the environment dismiss action is set.
      if let dismiss = dismiss {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .imageScale(.small)
        }
        .padding(20)
      }
    }
  }
}
