import SwiftUI
import LFUtilities

public struct TitleRow: View {
  public init(image: Image, title: String, style: CircleButton.Style?, trailingAction: (() -> Void)? = nil) {
    self.image = image
    self.title = title
    self.style = style
    self.trailingAction = trailingAction
  }

  let image: Image
  let title: String
  let style: CircleButton.Style?
  let trailingAction: (() -> Void)?

  public var body: some View {
    HStack(spacing: 16) {
      image
        .foregroundColor(Colors.label.swiftUIColor)
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
      if let style = style {
        CircleButton(style: style)
          .onTapGesture {
            trailingAction?()
          }
      }
    }
    .padding(.horizontal, 16)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
}
