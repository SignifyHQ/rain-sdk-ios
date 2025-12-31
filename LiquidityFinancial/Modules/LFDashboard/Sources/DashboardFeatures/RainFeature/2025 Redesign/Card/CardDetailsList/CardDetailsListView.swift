import Combine
import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import PassKit

public struct CardDetailsListView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: CardDetailsListViewModel
  @State private var cardHeight: CGFloat = 200
  
  public init(viewModel: CardDetailsListViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    Group {
      if viewModel.isInit {
        loadingView
      } else {
        contentView
      }
    }
    .onChange(of: viewModel.currentCard) { _, _ in
      viewModel.onCurrentCardChange()
    }
    .padding(.top, 4)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: viewModel.currentCard.cardType == .virtual ? L10N.Common.CardDetailsList.VirtualCard.Screen.title : L10N.Common.CardDetailsList.PhysicalCard.Screen.title)
    .isLoading($viewModel.isLoading)
    .navigationLink(
      item: $viewModel.navigation
    ) { item in
      switch item {
      case let .orderPhysicalCard(destinationView):
        destinationView
      case .creditLimitBreakdown:
        CreditLimitBreakdownView(
          viewModel: CreditLimitBreakdownViewModel()
        )
      case .disabledCardList:
        DisabledCardListView(cards: viewModel.closedCards)
      case .activatePhysicalCard:
        ActivatePhysicalCardView(card: viewModel.currentCard) { cardID in
          viewModel.activePhysicalSuccess(id: cardID)
        }
      case .shippingDetails:
        if let cardDetail = viewModel.cardDetail {
          ShippingDetailsView(
            cardDetail: cardDetail,
            onActivateSuccess: { cardId in
              viewModel.activePhysicalSuccess(id: cardId)
            },
            onDismiss: {
              viewModel.navigation = nil
            }
          )
        }
      }
    }
    .sheet(
      item: $viewModel.sheet
    ) { item in
      switch item {
      case let .applePay(destinationView):
        destinationView
      }
    }
    .sheetWithContentHeight(
      item: $viewModel.popup,
      interactiveDismissDisabled: viewModel.popup == .confirmLockCard,
      content: { popup in
        switch popup {
        case .confirmCloseCard:
          closeCardConfirmationPopup
        case .closeVirtualCardSuccessfully:
          virtualCardClosedSuccessfullyPopup
        case .closePhysicalCardSuccessfully:
          physicalCardClosedSuccessfullyPopup
        case .confirmCardOrderCancel:
          cancelCardOrderConfirmationPopup
        case .cardOrderCanceledSuccessfully:
          cardOrderCanceledSuccessfullyPopup
        case .confirmLockCard:
          lockCardPopup
        case .confirmCreateNewCard:
          createNewVirtualCardConfirmationPopup
        case .cardOrderSuccessfully:
          cardOrderSuccessPopup
        case .delayedCardOrder:
          DelayedCardOrderInfoView()
        }
      }
    )
    .toast(data: $viewModel.toastData)
    .onTapGesture {
      viewModel.isShowListCardDropdown = false
    }
    .task {
      if viewModel.isInit {
        return
      }
      
      viewModel.fetchRainCards(withLoader: false)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - Components
private extension CardDetailsListView {
  var loadingView: some View {
    VStack {
      DefaultLottieView(loading: .branded)
        .frame(width: 52, height: 52)
    }
    .frame(max: .infinity)
  }
  
  var contentView: some View {
    VStack(spacing: 24) {
      cardsView

      if let configurationValue = viewModel.requestConfiguration[viewModel.currentCard.id],
         let configuration = configurationValue,
         viewModel.shouldShowAddToWalletButton[viewModel.currentCard.id] == true {

        addToWalletButton(
          configuration: configuration
        )
        .frame(height: 48)
      }
      
      shippingInProgressView
      shippingPost30Days
      canceledCardOrderView
      actionCells
      Spacer()
      buttonGroupView
    }
  }

  var cardsView: some View {
    ZStack(alignment: .top) {
      ForEach(Array($viewModel.cardsList.enumerated()), id: \.element.id) { index, $card in
        CardDetailItemView(
          cardModel: $card,
          cardMetaData: $card.metadata,
          isShowCardNumber: $viewModel.isShowCardNumber,
          isLoading: $viewModel.isInit,
          hasBlurView: index != (viewModel.cardsList.count - 1)
        )
        .tag(card.id)
        .id(card.id)
        .offset(y: CGFloat(42 * index))
        .zIndex(Double(index))
        .background(
          GeometryReader { geometry in
            Color.clear.preference(
              key: CardHeightPreferenceKey.self,
              value: geometry.size.height
            )
          }
        )
        .onTapGesture {
          viewModel.onCardItemTap(card: card)
        }
      }
    }
    .frame(maxWidth: .infinity, minHeight: calculatedCardsHeight, alignment: .top)
    .onPreferenceChange(CardHeightPreferenceKey.self) { height in
      cardHeight = height
    }
  }
  
  private var calculatedCardsHeight: CGFloat {
    guard !viewModel.cardsList.isEmpty else { return cardHeight }
    let offsetSpacing: CGFloat = 42
    // Calculate total height: measured card height + offset for all cards except the first
    return cardHeight + (offsetSpacing * CGFloat(viewModel.cardsList.count - 1))
  }
  
  func addToWalletButton(configuration: PKAddPaymentPassRequestConfiguration) -> some View {
    AddPassToWalletButton(configuration) { response in
      guard let request = try? await viewModel
        .completeTokenization(
          certificates: response.certificates,
          nonce: response.nonce,
          nonceSignature: response.nonceSignature
        )
      else {
        log.error("Tokenization returned nil request.")
        return PKAddPaymentPassRequest()
      }
      
      return request
    } onCompletion: { result in
      switch result {
      case .success:
        viewModel.fetchRainCards()
        log.error("Card tokenized successfully!")
      case .failure(let error):
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  @ViewBuilder
  var actionCells: some View {
    VStack(
      alignment: .leading,
      spacing: 18
    ) {
      VStack(spacing: 0) {
        showCardNumberCell
        lockCardCell
        createNewVirtualCardCell
        shippingDetailsCell
        activatePhysicalCardCell
        orderPhysicalCardCell
        closeCardCell
        // Hiding it for now because it is not working, will update for v2
        //disabledCardsCell
      }
    }
  }
  
  @ViewBuilder
  var showCardNumberCell: some View {
    if viewModel.isShowingShowCardNumber {
      CardActionSwitchCell(
        title: L10N.Common.CardDetailsList.ShowCardNumber.title,
        icon: GenImages.Images.icoProfile.swiftUIImage,
        isOn: $viewModel.isShowCardNumber
      )
    }
  }
  
  @ViewBuilder
  var lockCardCell: some View {
    if viewModel.isShowingLockCard {
      let title = viewModel.currentCard.cardType == .virtual ? L10N.Common.CardDetailsList.LockVirtualCard.title : L10N.Common.CardDetailsList.LockPhysicalCard.title
      CardActionSwitchCell(
        title: title,
        subtitle: L10N.Common.CardDetailsList.LockCard.subtitle,
        isOn: $viewModel.isCardLocked,
        onChange: { isOn in
          if isOn && !viewModel.isSwitchCard {
            viewModel.popup = .confirmLockCard
          } else {
            viewModel.onLockCardToggle()
          }
        }
      )
    }
  }
  
  @ViewBuilder
  var shippingDetailsCell: some View {
    if viewModel.isShowingShippingDetails {
      CardActionCell(title: L10N.Common.CardDetailsList.ShippingDetails.title) {
        viewModel.navigation = .shippingDetails
      }
    }
  }
  
  @ViewBuilder
  var activatePhysicalCardCell: some View {
    if viewModel.isShowingShippingDetails {
      CardActionCell(title: L10N.Common.CardDetailsList.ActivatePhysicalCard.title) {
        viewModel.navigateActivateCardView()
      }
    }
  }
  
  @ViewBuilder
  var orderPhysicalCardCell: some View {
    if !viewModel.doesHavePhysicalCard || viewModel.isShowingCanceledCardOrder {
      CardActionCell(title: L10N.Common.CardDetailsList.OrderPhysical.title) {
        viewModel.onOrderPhysicalCardTap()
      }
    }
  }
  
  @ViewBuilder
  var closeCardCell: some View {
    if viewModel.isShowingCloseCard {
      CardActionCell(
        title: viewModel.currentCard.cardType == .virtual ? L10N.Common.CardDetailsList.CloseVirtualCard.title : L10N.Common.CardDetailsList.ClosePhysicalCard.title
      ) {
        viewModel.onCloseCardTap()
      }
    }
  }
  
  @ViewBuilder
  var disabledCardsCell: some View {
    if viewModel.isShowingDisabledCards {
      CardActionCell(title: L10N.Common.CardDetailsList.DisabledCards.title) {
        viewModel.navigation = .disabledCardList
      }
    }
  }
  
  @ViewBuilder
  var createNewVirtualCardCell: some View {
    if !viewModel.cardsList.contains(where: { $0.cardType == .virtual }) {
      CardActionCell(title: L10N.Common.CardDetailsList.CreateNewVirtualCard.title) {
        viewModel.popup = .confirmCreateNewCard
      }
    }
  }

  @ViewBuilder var buttonGroupView: some View {
    VStack(spacing: 12) {
      // Show cancel order button for pending card orderd
      if viewModel.currentCard.cardStatus == .pending {
        cancelCardOrderButton
      }
    }
  }
  
  var cancelCardOrderButton: some View {
    FullWidthButton(
      backgroundColor: Colors.secondaryBackground.swiftUIColor,
      title: L10N.Common.ListCard.CancelCardOrder.buttonTitle
    ) {
      viewModel.onCancelCardOrderTap()
    }
  }
  
  @ViewBuilder
  var shippingInProgressView: some View {
    if viewModel.isShowingShippingDetails
        && viewModel.isShowingShippingInProgress {
      ShippingInProgressView(
        showCloseButton: true,
        closeAction: {
          viewModel.isShowingShippingInProgress = false
        }
      )
    }
  }
  
  @ViewBuilder
  var shippingPost30Days: some View {
    if viewModel.isShowingShippingDetailPost30Days
        && viewModel.isShowingShippingPost30Days
        && !viewModel.isShowingShippingInProgress {
      ShippingPost30DaysView(
        showCloseButton: true,
        closeAction: {
          viewModel.isShowingShippingPost30Days = false
        },
        activateAction: {
          viewModel.navigateActivateCardView()
        },
        learnMoreAction: {
          viewModel.popup = .delayedCardOrder
        }
      )
    }
  }
  
  @ViewBuilder
  var canceledCardOrderView: some View {
    if viewModel.isShowingCanceledCardOrder {
      VStack(
        alignment: .leading,
        spacing: 12
      ) {
        VStack(
          alignment: .leading,
          spacing: 8
        ) {
          HStack(spacing: 8) {
            GenImages.Images.icoToastError.swiftUIImage
              .resizable()
              .frame(width: 20, height: 20)
            
            Text(L10N.Common.CardDetailsList.CanceledCardOrder.title)
              .foregroundColor(Colors.textPrimary.swiftUIColor)
              .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
              .fixedSize(horizontal: true, vertical: false)
            
            Spacer()
          }
          
          Text(L10N.Common.CardDetailsList.CanceledCardOrder.subtitle)
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .fixedSize(horizontal: false, vertical: true)
        }
        
        FullWidthButton(
          height: 32,
          tintColor: Colors.blue900.swiftUIColor,
          backgroundColor: Colors.grey25.swiftUIColor,
          title: L10N.Common.CardDetailsList.CanceledCardOrder.OrderAgain.Button.title,
          font: Fonts.semiBold.swiftUIFont(fixedSize: Constants.FontSize.small.value),
          action: {
            viewModel.onOrderPhysicalCardTap()
          }
        )
      }
      .padding(12)
      .background(Colors.grey500.swiftUIColor)
      .cornerRadius(8)
    }
  }
}

// MARK: - Popup
private extension CardDetailsListView {
  var lockCardPopup: some View {
    let cardText = viewModel.currentCard.cardType == .virtual ? "virtual card" : "physical card"
    return CommonBottomSheet(
      title: L10N.Common.LockCard.Popup.title(cardText),
      subtitle: L10N.Common.LockCard.Popup.subtitle(cardText),
      primaryButtonTitle: L10N.Common.LockCard.Popup.Confirm.Button.title(cardText),
      secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title,
      primaryAction: {
        viewModel.hidePopup()
        viewModel.onLockCardToggle()
      },
      secondaryAction: {
        viewModel.isCardLocked = false
        viewModel.hidePopup()
      }
    )
  }
  
  var closeCardConfirmationPopup: some View {
    let isVirtualCard: Bool = viewModel.currentCard.cardType == .virtual
    let title = isVirtualCard ? L10N.Common.CloseVirtualCard.Popup.title : L10N.Common.ClosePhysicalCard.Popup.title
    let subtitle = isVirtualCard ? L10N.Common.CloseVirtualCard.Popup.subtitle : L10N.Common.ClosePhysicalCard.Popup.subtitle
    let primaryButtonTitle = isVirtualCard ? L10N.Common.CloseVirtualCard.Popup.Confirm.Button.title : L10N.Common.ClosePhysicalCard.Popup.Confirm.Button.title
    
    return CommonBottomSheet(
      title: title,
      subtitle: subtitle,
      primaryButtonTitle: primaryButtonTitle,
      secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title,
      primaryAction: {
        viewModel.closeCard(with: isVirtualCard ? .virtual : .physical)
      },
      secondaryAction: {
        viewModel.hidePopup()
      }
    )
  }
  
  var cancelCardOrderConfirmationPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.ListCard.CancelCardOrder.title,
      subtitle: L10N.Common.ListCard.CancelCardOrder.message,
      primaryButtonTitle: L10N.Common.ListCard.CancelCardOrder.YesButton.title,
      secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title,
      primaryAction: {
        viewModel.cancelCardOrder()
      },
      secondaryAction: {
        viewModel.hidePopup()
      }
    )
  }
  
  var virtualCardClosedSuccessfullyPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.ClosedVirtualCardSuccess.Popup.title,
      subtitle: L10N.Common.ClosedVirtualCardSuccess.Popup.subtitle,
      primaryButtonTitle: L10N.Common.ClosedVirtualCardSuccess.Popup.RequestNew.Button.title,
      secondaryButtonTitle: L10N.Common.Common.MaybeLater.Button.title,
      primaryAction: {
        viewModel.hidePopup()
        viewModel.createNewCard()
      },
      secondaryAction: {
        viewModel.hidePopup()
        viewModel.showCardClosedSuccessfullyMessage()
      }
    )
  }
  
  var physicalCardClosedSuccessfullyPopup: some View {
    InfoBottomSheet(
      title: L10N.Common.ClosedPhysicalCardSuccess.Popup.title,
      subtitle: L10N.Common.ClosedPhysicalCardSuccess.Popup.subtitle,
      action: {
        viewModel.hidePopup()
      }
    )
  }
  
  var cardOrderCanceledSuccessfullyPopup: some View {
    InfoBottomSheet(
      title: L10N.Common.ListCard.CardOrderCanceled.title,
      subtitle: L10N.Common.ListCard.CardOrderCanceled.message,
      action: {
        viewModel.cardClosedSuccessAction {}
      }
    )
  }
  
  var createNewVirtualCardConfirmationPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.CardDetailsList.CreateNewVirtualCard.title,
      subtitle: L10N.Common.CreateNewVirtualCard.Popup.subtitle,
      primaryButtonTitle: L10N.Common.CardDetailsList.CreateNewVirtualCard.title,
      secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title,
      primaryAction: {
        viewModel.createNewCard()
      }
    )
  }
  
  var cardOrderSuccessPopup: some View {
    InfoBottomSheet(
      title: L10N.Common.OrderPhysicalCardSuccess.Popup.title,
      subtitle: L10N.Common.OrderPhysicalCardSuccess.Popup.subtitle,
      imageView: {
        GenImages.Images.physicalCardBackdrop.swiftUIImage
          .resizable()
          .frame(width: 88, height: 140)
      }
    )
  }
}

// PreferenceKey to measure card height
struct CardHeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}
