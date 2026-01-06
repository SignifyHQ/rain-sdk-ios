import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct ShippingAddressConfirmationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ShippingAddressConfirmationViewModel
  
  init(viewModel: ShippingAddressConfirmationViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      .background(Colors.baseAppBackground2.swiftUIColor)
      .appNavBar(navigationTitle: L10N.Common.OrderPhysicalCard.Screen.title)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .isLoading($viewModel.isOrderingCard)
  }
}

// MARK: - View Components
private extension ShippingAddressConfirmationView {
  var content: some View {
    VStack(alignment: .leading) {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          cardShippingView
          
          VStack(spacing: 16) {
            lineView
            ShippingInfoCell(
              title: L10N.Common.ShippingAddressConfirmation.ShippingTo
                .title,
              value: viewModel.fullName
            )
            
            ShippingInfoCell(
              title: L10N.Common.ShippingAddressConfirmation.PhoneNumber
                .title,
              value: viewModel.phoneNumber
            )
            
            ShippingInfoCell(
              title: L10N.Common.ShippingAddressConfirmation.Address
                .title,
              value: viewModel.shippingAddress.description
            )
          }
        }
        .padding(.top, 8)
      }
      
      Spacer()
      
      buttonGroup
    }
  }
  
  var cardShippingView: some View {
    VStack(alignment: .center, spacing: 24) {
      GenImages.Images.physicalCardBackdrop.swiftUIImage
        .resizable()
        .frame(width: 88, height: 140)
      
      Text(L10N.Common.ShippingAddressConfirmation.PhysicalCard.subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textSecondary.swiftUIColor)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
  }
  
  
  
  var buttonGroup: some View {
    VStack(spacing: 12) {
      FullWidthButton(
        title: L10N.Common.ShippingAddressConfirmation.PlaceOder.title
      ) {
        viewModel.orderPhysicalCard()
      }
      
      FullWidthButton(
        type: .secondary,
        backgroundColor: Colors.buttonSurfaceSecondary.swiftUIColor,
        borderColor: Colors.greyDefault.swiftUIColor,
        title: L10N.Common.ShippingAddressConfirmation.EditAddress.title
      ) {
        dismiss()
      }
    }
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}

struct ShippingInfoCell: View {
  let title: String
  let value: String
  
  var body: some View {
    VStack(
      spacing: 16
    ) {
      HStack {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textSecondary.swiftUIColor)
        
        Spacer()
        
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .multilineTextAlignment(.trailing)
      }
      
      lineView
    }
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
