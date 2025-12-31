import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct ShippingPost30DaysView: View {
  var showCloseButton: Bool = false
  var closeAction: (() -> Void)? = nil
  var activateAction: (() -> Void)? = nil
  var learnMoreAction: (() -> Void)? = nil
  
  var body: some View {
    VStack(
      alignment: .leading,
      spacing: 12
    ) {
      VStack(
        alignment: .leading,
        spacing: 8
      ) {
        HStack(spacing: 8) {
          GenImages.Images.icoShipping.swiftUIImage
            .resizable()
            .frame(width: 20, height: 20)
          
          Text(L10N.Common.CardDetailsList.ShippingPost30Days.title)
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
            .fixedSize(horizontal: true, vertical: false)
          
          Spacer()
          
          if showCloseButton {
            Button {
              closeAction?()
            } label: {
              Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10, alignment: .center)
                .foregroundColor(Colors.iconPrimary.swiftUIColor)
            }
            .frame(width: 20, height: 20)
          }
        }
        
        Text(L10N.Common.CardDetailsList.ShippingPost30Days.subtitle)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .fixedSize(horizontal: false, vertical: true)
      }
      
      buttonGroup
    }
    .padding(12)
    .background(Colors.blue700.swiftUIColor)
    .cornerRadius(8)
  }
}

extension ShippingPost30DaysView {
  var buttonGroup: some View {
    VStack(spacing: 8) {
      FullWidthButton(
        height: 32,
        tintColor: Colors.blue900.swiftUIColor,
        backgroundColor: Colors.grey25.swiftUIColor,
        title: L10N.Common.CardDetailsList.ActivateCard.title,
        font: Fonts.semiBold.swiftUIFont(fixedSize: Constants.FontSize.small.value),
        action: {
          activateAction?()
        }
      )
      
      Button {
        learnMoreAction?()
      } label: {
        HStack(alignment: .center, spacing: 8) {
          Text(L10N.Common.Common.LearnMore.Button.title)
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
          
          Image(systemName: "arrow.right")
            .resizable()
            .frame(width: 12, height: 12)
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
        }
      }
      .frame(height: 32)
    }
  }
}
