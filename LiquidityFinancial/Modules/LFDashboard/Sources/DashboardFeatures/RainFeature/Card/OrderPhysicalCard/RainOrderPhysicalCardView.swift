import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct RainOrderPhysicalCardView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  private var viewModel: RainOrderPhysicalCardViewModel
  
  init(viewModel: RainOrderPhysicalCardViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .navigationTitle(L10N.Common.OrderPhysicalCard.PhysicalCard.title)
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .shippingAddress(destinationView):
          destinationView
        }
      }
      .popup(isPresented: $viewModel.isShowOrderSuccessPopup) {
        orderPhysicalCardSuccessPopup
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
  }
}

// MARK: - View Components
private extension RainOrderPhysicalCardView {
  var content: some View {
    VStack(alignment: .leading) {
      ScrollView(showsIndicators: false) {
        VStack {
          GenImages.Images.physicalCard.swiftUIImage
            .padding(.vertical, 32)
          
          VStack(
            alignment: .leading,
            spacing: 18
          ) {
            GenImages.CommonImages.dash.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
            
            feesCell
            
            GenImages.CommonImages.dash.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
            
            cardReceivingAddress
          }
        }
      }
      
      Spacer()
      
      buttonGroup
    }
    .padding(.horizontal, 30)
  }
  
  var cardReceivingAddress: some View {
    VStack(
      alignment: .leading,
      spacing: 16
    ) {
      Text(L10N.Common.OrderPhysicalCard.Address.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      
      HStack(
        alignment: .center,
        spacing: 12
      ) {
        GenImages.CommonImages.icMap.swiftUIImage
          .frame(20)
          .foregroundColor(Colors.label.swiftUIColor)
        
        VStack(
          alignment: .leading,
          spacing: 4
        ) {
          Text(L10N.Common.OrderPhysicalCard.Address.subtitle)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          
          Text(viewModel.shippingAddress?.description ?? "")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
        }
        
        Spacer()
      }
      .padding(16)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(12))
    }
  }
  
  var feesCell: some View {
    HStack {
      Text(L10N.Common.OrderPhysicalCard.Fees.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      (
        Text(viewModel.fees.formattedUSDAmount())
          .foregroundColor(Colors.label.swiftUIColor)
        
        +
        
        Text(" ")
        
        +
        
        Text(L10N.Common.OrderPhysicalCard.Fees.Free.title)
          .foregroundColor(Colors.green.swiftUIColor)
      )
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
    }
  }
  
  var buttonGroup: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: L10N.Common.OrderPhysicalCard.EditAddress.buttonTitle,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.onClickedEditAddressButton(shippingAddress: $viewModel.shippingAddress)
      }
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: false,
        isLoading: $viewModel.isOrderingCard
      ) {
        viewModel.orderPhysicalCard()
      }
    }
    .padding(.bottom, 16)
  }
  
  var orderPhysicalCardSuccessPopup: some View {
    LiquidityAlert(
      title: L10N.Common.OrderPhysicalCard.OrderedSuccess.title,
      message: L10N.Common.OrderPhysicalCard.OrderedSuccess.message,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.primaryOrderSuccessAction()
        dismiss()
      }
    )
  }
}
