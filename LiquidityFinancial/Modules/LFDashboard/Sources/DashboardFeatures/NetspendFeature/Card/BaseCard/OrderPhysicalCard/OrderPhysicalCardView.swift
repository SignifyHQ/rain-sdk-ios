import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct OrderPhysicalCardView<ViewModel: OrderPhysicalCardViewModelProtocol>: View {
  @StateObject private var viewModel: ViewModel
  @ObservedObject var coordinator: BaseCardDestinationObservable
  
  public init(viewModel: ViewModel, coordinator: BaseCardDestinationObservable) {
   _viewModel = .init(wrappedValue: viewModel)
    self.coordinator = coordinator
  }
  
  public var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        physicalCardView
        VStack(alignment: .leading, spacing: 24) {
          feesCell
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          cardReceivingAddress
        }
        Spacer()
        buttonGroup
      }
      .padding(.horizontal, 30)
    }
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $coordinator.orderPhysicalCardDestinationObservable.navigation) { navigation in
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
private extension OrderPhysicalCardView {
  var physicalCardView: some View {
    VStack(spacing: 36) {
      GenImages.Images.physicalCard.swiftUIImage
      Text(LFLocalizable.OrderPhysicalCard.PhysicalCard.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  var cardReceivingAddress: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(LFLocalizable.OrderPhysicalCard.Address.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      HStack(alignment: .top, spacing: 12) {
        GenImages.CommonImages.icMap.swiftUIImage
          .frame(20)
          .foregroundColor(Colors.label.swiftUIColor)
        Text(viewModel.shippingAddress?.description ?? "")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .multilineTextAlignment(.leading)
          .lineLimit(3)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.trailing, 50)
    }
  }
  
  var feesCell: some View {
    HStack {
      Text(LFLocalizable.OrderPhysicalCard.Fees.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      Spacer()
      Text(viewModel.fees.formattedUSDAmount())
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  var buttonGroup: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: LFLocalizable.OrderPhysicalCard.EditAddress.buttonTitle,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.onClickedEditAddressButton(shippingAddress: $viewModel.shippingAddress)
      }
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
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
      title: LFLocalizable.OrderPhysicalCard.OrderedSuccess.title,
      message: LFLocalizable.OrderPhysicalCard.OrderedSuccess.message,
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        viewModel.primaryOrderSuccessAction()
        coordinator.listCardsDestinationObservable.navigation = nil
      }
    )
  }
}
