import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct WalletAddressInputView: View {
  @Binding public var walletAddress: String
  
  let onScanButtonTap: (() -> Void)?
  
  public init(
    walletAddress: Binding<String>,
    onScanButtonTap: (() -> Void)?
  ) {
    self._walletAddress = walletAddress
    self.onScanButtonTap = onScanButtonTap
  }
  
  public var body: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      Text(L10N.Common.WalletAddressInput.Input.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .multilineTextAlignment(.leading)
      
      HStack(
        spacing: 10
      ) {
        DefaultTextField(
          placeholder: L10N.Common.WalletAddressInput.Input.placeholder,
          isDividerShown: false,
          value: $walletAddress,
          tint: Colors.textPrimary.swiftUIColor,
          submitLabel: .done,
          textColor: Colors.textPrimary.swiftUIColor,
          placeholderColor: Colors.textSecondary2.swiftUIColor,
        )
        
        trailingButtonView
      }
      
      Divider()
        .background(Colors.dividerPrimary.swiftUIColor)
        .frame(height: 1, alignment: .center)
    }
  }
  
  var trailingButtonView: some View {
    GenImages.Images.icoScanner.swiftUIImage
      .resizable()
      .frame(
        width: 24,
        height: 24
      )
      .onTapGesture {
        onScanButtonTap?()
      }
  }
}
