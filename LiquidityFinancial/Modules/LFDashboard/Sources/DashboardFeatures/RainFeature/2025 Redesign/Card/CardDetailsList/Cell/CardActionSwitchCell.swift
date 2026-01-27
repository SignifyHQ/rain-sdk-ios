import SwiftUI
import LFStyleGuide
import LFUtilities

struct CardActionSwitchCell: View {
  let title: String
  var subtitle: String? = nil
  var icon: Image? = nil
  @Binding var isOn: Bool
  var onChange: ((Bool) -> Void)? = nil
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Toggle(isOn: $isOn) {
        HStack(spacing: 12) {
          if let icon {
            icon
              .resizable()
              .frame(width: 24, height: 24)
          }
          
          VStack(spacing: 3) {
            Text(title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundStyle(Colors.textPrimary.swiftUIColor)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            if let subtitle {
              Text(subtitle)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
                .foregroundStyle(Colors.textSecondary.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
      }
      .padding(.horizontal, 8)
      .onChange(of: isOn) { value in
        onChange?(value)
      }
      
      lineView
    }
    .padding(.top, 16)
  }
}

extension CardActionSwitchCell {
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
