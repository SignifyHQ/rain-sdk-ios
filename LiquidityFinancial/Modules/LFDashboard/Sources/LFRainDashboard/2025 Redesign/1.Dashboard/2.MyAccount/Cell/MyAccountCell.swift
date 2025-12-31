import SwiftUI
import LFStyleGuide
import LFUtilities

struct MyAccountCell: View {
  let item: MyAccountViewModel.MyAccountItem
  var action: (() -> Void)? = nil
  
  var body: some View {
    Button {
      action?()
    } label: {
      VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 12) {
          item.icon
            .resizable()
            .frame(width: 24, height: 24)
          
          Text(item.title)
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

extension MyAccountCell {
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
