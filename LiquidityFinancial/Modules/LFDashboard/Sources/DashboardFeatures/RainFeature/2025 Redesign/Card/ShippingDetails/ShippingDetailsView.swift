import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct ShippingDetailsView: View {
  @StateObject private var viewModel: ShippingDetailsViewModel
  
  let onActivateSuccess: ((String) -> Void)?
  let onDismiss: (() -> Void)?
  
  init(
    cardDetail: CardDetail,
    onActivateSuccess: ((String) -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    _viewModel = .init(wrappedValue: ShippingDetailsViewModel(cardDetail: cardDetail))
    self.onActivateSuccess = onActivateSuccess
    self.onDismiss = onDismiss
  }
  
  var body: some View {
    VStack(spacing: 24) {
      if viewModel.isShowingShippingDetailPost30Days {
        shippingPost30DaysView
      } else {
        shippingInProgressView
      }
      
      timeView
      infoView
      Spacer()
    }
    .appNavBar(navigationTitle: L10N.Common.CardDetailsList.ShippingDetails.title)
    .padding(.top, 8)
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .navigationLink(
      item: $viewModel.navigation
    ) { item in
      switch item {
      case .activatePhysicalCard:
        ActivatePhysicalCardView(
          card: viewModel.cardDetail.toCardModel(),
          onSuccess: { cardID in
            onActivateSuccess?(cardID)
          },
          onDismiss: onDismiss
        )
      }
    }
    .sheetWithContentHeight(
      item: $viewModel.popup,
      content: { popup in
        switch popup {
        case .delayedCardOrder:
          DelayedCardOrderInfoView()
        }
      }
    )
  }
}

extension ShippingDetailsView {
  @ViewBuilder
  var shippingInProgressView: some View {
    ShippingInProgressView()
  }
  
  var shippingPost30DaysView: some View {
    ShippingPost30DaysView(
      activateAction: {
        viewModel.navigation = .activatePhysicalCard
      },
      learnMoreAction: {
        viewModel.popup = .delayedCardOrder
      }
    )
  }
  
  var timeView: some View {
    Text(L10N.Common.ShippingAddressConfirmation.PhysicalCard.subtitle)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      .foregroundColor(Colors.textSecondary.swiftUIColor)
      .multilineTextAlignment(.center)
  }
  
  var infoView: some View {
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
      
      if let address = viewModel.cardDetail.shippingAddress?.toShippingAddress().description {
        ShippingInfoCell(
          title: L10N.Common.ShippingAddressConfirmation.Address
            .title,
          value: address
        )
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
