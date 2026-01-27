import SwiftUI
import LFStyleGuide
import LFUtilities

struct CardActionCell: View {
  let title: String
  let subtitle: String?
  let action: (() -> Void)?
  
  init(
    title: String,
    subtitle: String? = nil,
    action: (() -> Void)? = nil,
  ) {
    self.title = title
    self.subtitle = subtitle
    self.action = action
  }
  
  var body: some View {
    Button {
      action?()
    } label: {
      VStack(
        alignment: .leading,
        spacing: 16
      ) {
        HStack(
          spacing: 12
        ) {
          VStack(
            alignment: .leading,
            spacing: 3
          ) {
            Text(title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundStyle(Colors.textPrimary.swiftUIColor)
            
            if let subtitle {
              Text(subtitle)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
                .foregroundStyle(Colors.textSecondary.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        
        lineView
      }
    }
    .padding(.top, 16)
  }
}

extension CardActionCell {
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
