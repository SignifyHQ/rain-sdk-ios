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
            .padding(.top, 8)
            .padding(.bottom, 16)
          
          VStack(
            alignment: .leading,
            spacing: 18
          ) {
            HStack {
              Spacer()
              
              Text(L10N.Common.OrderPhysicalCard.PhysicalCard.subtitle)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .multilineTextAlignment(.center)
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.7))
              
              Spacer()
            }
            
            GenImages.CommonImages.dash.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
            
            feesCell
            
            if !viewModel.walletAddress.isEmpty {
              GenImages.CommonImages.dash.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
              
              walletAddressCell
            }
            
            if viewModel.shippingAddress != nil {
              cardReceivingAddress
            }
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
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      
      Spacer()
      
      (
        Text(viewModel.fees.formattedUSDAmount())
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        
        +
        
        Text(" ")
        
        +
        
        Text("AVAX")
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.primary.swiftUIColor)
      )
    }
  }
  
  var walletAddressCell: some View {
    HStack(
      alignment: .top
    ) {
      Text(L10N.Common.OrderPhysicalCard.WalletAddress.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      
      Spacer(minLength: 32)
      
      Text(viewModel.walletAddress)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.trailing)
        .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  var buttonGroup: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: viewModel.shippingAddress != nil ? L10N.Common.OrderPhysicalCard.EditAddress.buttonTitle : L10N.Common.OrderPhysicalCard.AddAddress.buttonTitle,
        isDisable: false,
        type: viewModel.shippingAddress != nil ? .secondary : .primary
      ) {
        viewModel.onClickedEditAddressButton(shippingAddress: $viewModel.shippingAddress)
      }
      
      if viewModel.shippingAddress != nil {
        FullSizeButton(
          title: L10N.Common.Button.Continue.title,
          isDisable: false,
          isLoading: $viewModel.isOrderingCard
        ) {
          viewModel.orderPhysicalCard()
        }
      }
    }
    .padding(.top, 8)
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
