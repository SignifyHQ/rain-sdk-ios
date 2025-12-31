import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct ShippingInProgressView: View {
  var showCloseButton: Bool = false
  var closeAction: (() -> Void)? = nil
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        GenImages.Images.icoShipping.swiftUIImage
          .resizable()
          .frame(width: 20, height: 20)
        
        Text(L10N.Common.CardDetailsList.ShippingInProgress.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
        
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
      
      Text(L10N.Common.CardDetailsList.ShippingInProgress.subtitle)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
    }
    .padding(12)
    .background(Colors.blue700.swiftUIColor)
    .cornerRadius(8)
  }
}
