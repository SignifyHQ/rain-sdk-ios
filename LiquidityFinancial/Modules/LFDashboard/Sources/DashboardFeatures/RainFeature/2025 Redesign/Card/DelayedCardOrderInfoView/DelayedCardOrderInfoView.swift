import LFLocalizable
import LFUtilities
import SwiftUI
import LFStyleGuide

public struct DelayedCardOrderInfoView: View {
  @Environment(\.dismiss) private var dismiss
  
  public var body: some View {
    VStack(spacing: 32) {
      headerView
      contentView
      buttonsGroup
        .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .background(Colors.grey900.swiftUIColor)
  }
}

private extension DelayedCardOrderInfoView {
  var headerView: some View {
    Text("Why your physical card order might be delayed")
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .multilineTextAlignment(.center)
      .padding(.top, 24)
  }
  
  @ViewBuilder
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 32
    ) {
      VStack(
        alignment: .leading,
        spacing: 16
      ) {
        Text("We apologize for the inconvenience caused by a delay in your physical card shipment. In some cases, card orders can take longer than usual due to one of the following reasons:")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
        
        VStack(
          alignment: .leading,
          spacing: 16
        ) {
          (Text("• Address issues:")
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
           + Text(" The shipping address entered may not have been processed correctly by our delivery partners.")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          )
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          
          (Text("• Special characters in name:")
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
           + Text(" Occasionally, names with special characters (such as accents or symbols) may take longer to process.")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          )
          .foregroundColor(Colors.textPrimary.swiftUIColor)
        }
        .padding(.leading, 12)
      }
      
      VStack(
        alignment: .leading,
        spacing: 16
      ) {
        Text("How to resolve this?")
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
        
        VStack(
          alignment: .leading,
          spacing: 16
        ) {
          (Text("• Double-check your shipping address in the “")
           
           + Text("Card shipping details")
            .underline()
           
           + Text("” section and, if needed, contact our support team.")
          )
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          
          Text("• If your name includes special characters, please contact our support team and they’ll help ensure your order is processed correctly.")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.textPrimary.swiftUIColor)
        }
        .padding(.leading, 12)
        
        Text("We appreciate your patience and are working to get your card to you as soon as possible.")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
      }
    }
  }
  
  var buttonsGroup: some View {
    closeButton
      .frame(maxWidth: .infinity)
  }
  
  var closeButton: some View {
    FullWidthButton(
      height: 40,
      title: L10N.Common.Common.Close.Button.title,
      action: {
        dismiss()
      }
    )
  }
}
