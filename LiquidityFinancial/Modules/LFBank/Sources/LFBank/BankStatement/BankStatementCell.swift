import SwiftUI
import LFStyleGuide
import LFUtilities

struct BankStatementCell: View {
  let title: String
  let detailTitle: String
  let leftImage: ImageAsset?
  var backGroundColor: Color
  var titleColor: Color
  var action: () -> Void = {}

  init(
    title: String,
    detailTitle: String,
    leftImage: ImageAsset? = nil,
    backGroundColor: Color = Colors.secondaryBackground.swiftUIColor,
    titleColor: Color = Colors.label.swiftUIColor,
    action: @escaping () -> Void = {}
  ) {
    self.title = title
    self.detailTitle = detailTitle
    self.leftImage = leftImage
    self.backGroundColor = backGroundColor
    self.titleColor = titleColor
    self.action = action
  }

  var body: some View {
    Button {
      action()
    } label: {
      VStack {
        HStack(alignment: .center) {
          if let image = leftImage {
            image.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
          }
          VStack {
            Text(title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
              .foregroundColor(titleColor)
              .frame(maxWidth: .infinity, alignment: .leading)
            Text(detailTitle)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.50))
              .frame(maxWidth: .infinity, alignment: .leading)
          }.padding(.leading, 5)

          Spacer()

          CircleButton(style: .right)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .frame(height: 56)
        .padding(.horizontal, 16)
        .background(backGroundColor)
        .cornerRadius(12)
        .buttonStyle(PlainButtonStyle())
      }
    }
    .buttonStyle(PlainButtonStyle())
  }
}
