import SwiftUI
import LFStyleGuide
import LFUtilities

struct MyAccountSwitchCell: View {
  let item: MyAccountViewModel.MyAccountItem
  @Binding var isOn: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Toggle(isOn: $isOn) {
        HStack(spacing: 12) {
          item.icon
            .resizable()
            .frame(width: 24, height: 24)
          Text(item.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(.horizontal, 8)
      
      lineView
    }
    .padding(.top, 16)
  }
}

extension MyAccountSwitchCell {
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
