import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct ShippingDetailsView: View {
  @StateObject private var viewModel: ShippingDetailsViewModel
  
  let onActivateSuccess: ((String) -> Void)
  let onDismiss: (() -> Void)
  
  init(
    cardDetail: CardDetail,
    onActivateSuccess: @escaping ((String) -> Void),
    onCardOrderCancelSuccess: @escaping ((Bool) -> Void),
    onDismiss: @escaping (() -> Void)
  ) {
    _viewModel = .init(
      wrappedValue: ShippingDetailsViewModel(
        cardDetail: cardDetail,
        onCardOrderCancelSuccess: onCardOrderCancelSuccess
      )
    )
    
    self.onActivateSuccess = onActivateSuccess
    self.onDismiss = onDismiss
  }
  
  var body: some View {
    VStack(
      spacing: 24
    ) {
      if viewModel.isShowingShippingDetailPost30Days {
        shippingPost30DaysView
      } else {
        shippingInProgressView
      }
      
      timeView
      infoView
      cancelCardOrderButton
      
      Spacer()
    }
    .padding(.top, 8)
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(
      navigationTitle: L10N.Common.CardDetailsList.ShippingDetails.title
    )
    .toast(
      data: $viewModel.toastData
    )
    .withLoadingIndicator(
      isShowing: $viewModel.isLoading,
      isOpaque: false
    )
    .sheetWithContentHeight(
      item: $viewModel.popup,
      interactiveDismissDisabled: viewModel.popup == .cardOrderCanceledSuccessfully,
      content: { popup in
        switch popup {
        case .confirmCardOrderCancel:
          cancelCardOrderConfirmationPopup
        case .cardOrderCanceledSuccessfully:
          cardOrderCanceledSuccessfullyPopup
        case .delayedCardOrder:
          DelayedCardOrderInfoView()
        }
      }
    )
    .navigationLink(
      item: $viewModel.navigation
    ) { item in
      switch item {
      case .activatePhysicalCard:
        ActivatePhysicalCardView(
          card: viewModel.cardDetail.toCardModel(),
          onSuccess: { cardID in
            onActivateSuccess(cardID)
          },
          onDismiss: onDismiss
        )
      }
    }
  }
}

// MARK: - View Components
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
        value: viewModel.fullName,
        shouldShowDivider: true
      )
      
      ShippingInfoCell(
        title: L10N.Common.ShippingAddressConfirmation.PhoneNumber
          .title,
        value: viewModel.phoneNumber,
        shouldShowDivider: true
      )
      
      if let address = viewModel.cardDetail.shippingAddress?.toShippingAddress().description {
        ShippingInfoCell(
          title: L10N.Common.ShippingAddressConfirmation.Address
            .title,
          value: address,
          shouldShowDivider: false
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
  
  @ViewBuilder
  var cancelCardOrderButton: some View {
    if viewModel.isShowingCancelCardOrderButton {
      FullWidthButton(
        type: .primary,
        title: L10N.Common.ListCard.CancelCardOrder.buttonTitle
      ) {
        viewModel.onCancelCardOrderTap()
      }
    }
  }
  
  var cancelCardOrderConfirmationPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.ListCard.CancelCardOrder.title,
      subtitle: L10N.Common.ListCard.CancelCardOrder.message,
      primaryButtonTitle: L10N.Common.ListCard.CancelCardOrder.YesButton.title,
      secondaryButtonTitle: L10N.Common.ListCard.CancelCardOrder.CancelButton.title,
      imageView: {
        GenImages.Images.physicalCardBackdrop.swiftUIImage
          .resizable()
          .frame(width: 88, height: 140)
      },
      primaryAction: {
        viewModel.onConfirmCancelCardOrderTap(shouldTakeToNewCardOrder: true)
      },
      secondaryAction: {
        viewModel.onConfirmCancelCardOrderTap()
      }
    )
  }
  
  var cardOrderCanceledSuccessfullyPopup: some View {
    InfoBottomSheet(
      title: L10N.Common.ListCard.CardOrderCanceled.title,
      subtitle: L10N.Common.ListCard.CardOrderCanceled.message,
      action: {
        viewModel.onCardOrderCancelSuccessCloseTap()
      }
    )
  }
}
