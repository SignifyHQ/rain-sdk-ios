import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct WalletAddressNicknameTextField: View {
  @Binding public var nickname: String
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L10N.Common.SaveWalletAddress.Input.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .multilineTextAlignment(.leading)
      
      DefaultTextField(
        placeholder: L10N.Common.SaveWalletAddress.Input.placeholder,
        isDividerShown: true,
        value: $nickname,
        tint: Colors.textPrimary.swiftUIColor,
        submitLabel: .done,
        textColor: Colors.textPrimary.swiftUIColor,
        placeholderColor: Colors.textSecondary2.swiftUIColor
      )
      
      Text(L10N.Common.SaveWalletAddress.Input.note)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.textTertiary.swiftUIColor)
    }
  }
}
