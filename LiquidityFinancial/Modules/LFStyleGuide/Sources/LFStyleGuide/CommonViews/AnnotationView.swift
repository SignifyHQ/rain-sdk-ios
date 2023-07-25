import SwiftUI
import LFUtilities

public struct AnnotationView: View {
  private let description: String
  private let radius: CGFloat

  public init(description: String, radius: CGFloat = 16) {
    self.description = description
    self.radius = radius
  }

  public var body: some View {
    Text(description)
      .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
      .lineSpacing(6)
      .multilineTextAlignment(.leading)
      .padding(12)
      .background(
        Colors.secondaryBackground.swiftUIColor.cornerRadius(
          radius,
          corners: [.topLeft, .bottomLeft, .bottomRight]
        )
      )
  }
}
