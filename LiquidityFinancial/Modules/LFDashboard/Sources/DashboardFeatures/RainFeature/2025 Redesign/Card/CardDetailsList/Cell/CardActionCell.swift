import SwiftUI
import LFStyleGuide
import LFUtilities

struct CardActionCell: View {
  let title: String
  var action: (() -> Void)? = nil
  
  var body: some View {
    Button {
      action?()
    } label: {
      VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 12) {
          Text(title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
          
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
