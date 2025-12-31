import SwiftUI
import LFUtilities

public struct AnnotationView: View {
  private let description: String
  private let radius: CGFloat
  private let corners: UIRectCorner

  public init(description: String, radius: CGFloat = 16, corners: UIRectCorner) {
    self.description = description
    self.radius = radius
    self.corners = corners
  }

  public var body: some View {
    Text(description)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
      .lineSpacing(6)
      .multilineTextAlignment(.leading)
      .padding(12)
      .background(
        Colors.secondaryBackground.swiftUIColor.cornerRadius(
          radius,
          corners: corners
        )
      )
  }
}
