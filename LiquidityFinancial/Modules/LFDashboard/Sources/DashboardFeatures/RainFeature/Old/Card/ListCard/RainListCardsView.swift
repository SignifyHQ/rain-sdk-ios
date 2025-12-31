import Combine
import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import PassKit

public struct RainListCardsView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: RainListCardsViewModel
  
  public init(viewModel: RainListCardsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack(
      alignment: .top
    ) {
      if viewModel.isInit {
        loadingView
      } else {
        cardDetails
      }
    }
    .onChange(of: viewModel.currentCard) { _ in
      viewModel.onChangeCurrentCard()
    }
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
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
      }
    }
    .overlay(
      cardsList.padding(.top, 0),
      alignment: .top
    )
    .sheet(
      item: $viewModel.sheet
    ) { item in
      switch item {
      case let .applePay(destinationView):
        destinationView
      }
    }
    .fullScreenCover(
      item: $viewModel.fullScreen
    ) { item in
      switch item {
      case let .activatePhysicalCard(destinationView):
        destinationView
          .embedInNavigation()
      }
    }
    .popup(
      item: $viewModel.popup,
      dismissMethods: .tapInside
    ) { item in
      switch item {
      case .confirmCloseCard:
        closeCardConfirmationPopup
      case .closeCardSuccessfully:
        cardClosedSuccessfullyPopup
      case .confirmCardOrderCancel:
        cancelCardOrderConfirmationPopup
      case .cardOrderCanceledSuccessfully:
        cardOrderCanceledSuccessfullyPopup
      default: EmptyView()
      }
    }
    .popup(
      item: $viewModel.toastMessage,
      style: .toast
    ) {
      ToastView(toastMessage: $0)
    }
    .onTapGesture {
      viewModel.isShowListCardDropdown = false
    }
    .onAppear {
      viewModel.fetchRainCards()
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - ToolBar Components
private extension RainListCardsView {
  var cardSwitchButton: some View {
    Button {
      viewModel.isShowListCardDropdown.toggle()
    } label: {
      VStack(
        alignment: .leading
      ) {
        HStack {
          (
            Text(viewModel.title(for: viewModel.currentCard).title)
              .foregroundColor(Colors.label.swiftUIColor)
            
            +
            
            Text(viewModel.title(for: viewModel.currentCard).lastFour)
              .foregroundColor(Colors.primary.swiftUIColor)
          )
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
          
          Image(systemName: viewModel.isShowListCardDropdown ? "chevron.up" : "chevron.down")
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.custom(size: 8).value))
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 8)
      .frame(width: 170)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(4))
    }
  }
}

// MARK: - Content Components
private extension RainListCardsView {
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(max: .infinity)
  }
  
  var cardDetails: some View {
    VStack {
      card

      if let configurationValue = viewModel.requestConfiguration[viewModel.currentCard.id],
         let configuration = configurationValue,
         viewModel.shouldShowAddToWalletButton[viewModel.currentCard.id] == true {

        addToWalletButton(
          configuration: configuration
        )
        .frame(
          width: Screen.main.bounds.width - 60,
          height: 44
        )
        .padding(.bottom)
      }
      
      rows
        .padding(.horizontal, 30)
      
      Spacer()
      
      buttonGroup
        .padding(.horizontal, 30)
    }
    .overlay {
      if viewModel.isLoading {
        ProgressView().progressViewStyle(.circular)
          .tint(Colors.primary.swiftUIColor)
      }
    }
    .disabled(viewModel.isLoading)
    .padding(.bottom, 10)
  }
}

// MARK: - Top Components
private extension RainListCardsView {
  var toolbarContent: some ToolbarContent {
    Group {
      if viewModel.activeCardCount > 1 {
        ToolbarItem(placement: .principal) {
          cardSwitchButton
        }
      }
    }
  }
  
  @ViewBuilder
  var cardsList: some View {
    if viewModel.isShowListCardDropdown {
      VStack(alignment: .leading, spacing: 16) {
        ForEach(viewModel.cardsList, id: \.id) { item in
          HStack {
            (
              Text(viewModel.title(for: item).title)
                .foregroundColor(Colors.label.swiftUIColor)
              
              +
              
              Text(viewModel.title(for: item).lastFour)
                .foregroundColor(Colors.primary.swiftUIColor)
            )
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            
            Spacer()
            
            Image(systemName: "checkmark")
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.custom(size: 10).value))
              .foregroundColor(viewModel.currentCard.id == item.id ? Colors.primary.swiftUIColor : .clear)
          }
          .frame(height: 14)
          .onTapGesture {
            viewModel.currentCard = item
            viewModel.isShowListCardDropdown.toggle()
          }
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 12)
      .frame(width: 170)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(4))
    }
  }
  
  var card: some View {
    TabView(
      selection: $viewModel.currentCardId
    ) {
      ForEach($viewModel.cardsList) { $card in
        RainCardView(
          cardModel: card,
          cardMetaData: $card.metadata,
          isShowCardNumber: $viewModel.isShowCardNumber,
          isLoading: $viewModel.isInit
        )
        .padding(.horizontal, 30)
        .tag(card.id)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .frame(maxHeight: 240)
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
      case .success(let _):
        viewModel.fetchRainCards()
        log.error("Card tokenized successfully!")
      case .failure(let error):
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  @ViewBuilder
  var pageIndicator: some View {
    if viewModel.cardsList.count > 1 {
      HStack(spacing: 12) {
        ForEach(viewModel.cardsList) { card in
          Circle()
            .fill(
              Colors.label.swiftUIColor.opacity(viewModel.currentCard == card ? 1 : 0.3)
            )
            .frame(5)
        }
      }
      .padding(.top, 35)
    }
  }
}

// MARK: - Middle Components
private extension RainListCardsView {
  @ViewBuilder
  var rows: some View {
    VStack(
      alignment: .leading,
      spacing: 18
    ) {
      VStack {
        if viewModel.currentCard.cardType == .physical && (viewModel.currentCard.cardStatus == .unactivated || viewModel.currentCard.cardStatus == .pending) {
          shippingInfoView
        }
        
        if viewModel.currentCard.cardStatus == .pending {
          cardReceivingAddressView
        }
      }
      
      if viewModel.currentCard.cardType != .physical || (viewModel.currentCard.cardStatus != .unactivated && viewModel.currentCard.cardStatus != .pending) {
        Text(L10N.Common.ListCard.Security.title)
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      
      VStack(spacing: 16) {
        if viewModel.currentCard.cardType != .physical && viewModel.currentCard.cardStatus == .active {
          row(
            title: L10N.Common.ListCard.ShowCardNumber.title.localizedString,
            subtitle: nil,
            isSwitchOn: $viewModel.isShowCardNumber,
            onChange: nil
          )
          
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
        
        if viewModel.currentCard.cardStatus != .unactivated && viewModel.currentCard.cardStatus != .pending {
          row(
            title: L10N.Common.ListCard.LockCard.title,
            subtitle: L10N.Common.ListCard.LockCard.description,
            isSwitchOn: $viewModel.isCardLocked
          ) { _ in
            viewModel.lockCardToggled()
          }
        }
        
        if ![.closed, .disabled, .unactivated, .pending].contains(viewModel.currentCard.cardStatus) {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          row(title: L10N.Common.ListCard.CloseCard.title) {
            viewModel.onTapCloseCard()
          }
        }
      }
    }
  }
  
  func row(
    title: String,
    subtitle: String?,
    isSwitchOn: Binding<Bool>,
    onChange: ((Bool) -> Void)?
  ) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        if let subtitle {
          Text(subtitle)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
      }
      Spacer()
      Toggle("", isOn: isSwitchOn)
        .toggleStyle(
          SwitchToggleStyle(tint: Colors.primary.swiftUIColor)
        )
        .onChange(of: isSwitchOn.wrappedValue) { value in
          onChange?(value)
        }
    }
  }
  
  func row(
    title: String,
    onTap: @escaping () -> Void
  ) -> some View {
    Button(action: onTap) {
      HStack {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        GenImages.CommonImages.icRightArrow.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.trailing, 4)
      }
    }
  }
  
  var shippingInfoView: some View {
    HStack(
      alignment: .center,
      spacing: 12
    ) {
      GenImages.CommonImages.icShipping.swiftUIImage
      
      Text(L10N.Common.OrderPhysicalCard.Delivery.Full.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
      
      Spacer()
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Colors.secondaryBackground.swiftUIColor)
    )
  }
  
  var cardReceivingAddressView: some View {
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
          Text(L10N.Common.OrderPhysicalCard.Address.Delivery.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          
          Text(viewModel.currentCard.shippingAddress?.description ?? "")
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
}

// MARK: - Bottom Components
private extension RainListCardsView {
  @ViewBuilder var buttonGroup: some View {
    VStack(spacing: 14) {
      // Show activate card button for shipped physical card
      if viewModel.currentCard.cardStatus == .unactivated {
        activateCardButton
      }
      
      // Show cancel order button for pending card orderd
      if viewModel.currentCard.cardStatus == .pending {
        cancelCardOrderButton
      }
      
      // Show button for ordering a new physical card if it hasn't been shipped yet
      if !viewModel.doesHavePhysicalCard {
        orderPhysicalCardButton
      }
    }
  }
  
  var orderPhysicalCardButton: some View {
    FullSizeButton(
      title: L10N.Common.ListCard.OrderPhysicalCard.title,
      isDisable: false
    ) {
      viewModel.onTapOrderPhysicalCard()
    }
  }
  
  var activateCardButton: some View {
    FullSizeButton(
      title: L10N.Common.ListCard.ActivateCard.buttonTitle(viewModel.currentCard.cardType.title),
      isDisable: false
    ) {
      viewModel.presentActivateCardView(
        activeCardView: AnyView(
          RainActivePhysicalCardView(card: viewModel.currentCard) { cardID in
            viewModel.activePhysicalSuccess(id: cardID)
          }
        )
      )
    }
  }
  
  var cancelCardOrderButton: some View {
    FullSizeButton(
      title: L10N.Common.ListCard.CancelCardOrder.buttonTitle,
      isDisable: false,
      type: .tertiary
    ) {
      viewModel.onTapCancelCardOrder()
    }
  }
}

// MARK: - Popup
private extension RainListCardsView {
  var closeCardConfirmationPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ListCard.CloseCard.title.uppercased(),
      message: L10N.Common.ListCard.CloseCard.message,
      primary: .init(
        text: L10N.Common.ListCard.CloseCard.YesButton.title,
        action: {
          viewModel.closeCard()
        }
      ),
      secondary: .init(
        text: L10N.Common.ListCard.CloseCard.CancelButton.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
  
  var cancelCardOrderConfirmationPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ListCard.CancelCardOrder.title.uppercased(),
      message: L10N.Common.ListCard.CancelCardOrder.message,
      primary: .init(
        text: L10N.Common.ListCard.CancelCardOrder.YesButton.title,
        action: {
          viewModel.cancelCardOrder()
        }
      ),
      secondary: .init(
        text: L10N.Common.ListCard.CancelCardOrder.CancelButton.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
  
  var cardClosedSuccessfullyPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ListCard.CardClosed.title,
      message: L10N.Common.ListCard.CardClosed.message,
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.cardClosedSuccessAction {
            dismiss()
          }
        }
      )
    )
  }
  
  var cardOrderCanceledSuccessfullyPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ListCard.CardOrderCanceled.title.uppercased(),
      message: L10N.Common.ListCard.CardOrderCanceled.message,
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.cardClosedSuccessAction {
            dismiss()
          }
        }
      )
    )
  }
}

struct AddPassButton: UIViewRepresentable {
  func makeUIView(context: Context) -> PKAddPassButton {
    let button = PKAddPassButton(addPassButtonStyle: .blackOutline)
    
    return button
  }
  
  func updateUIView(_ uiView: PKAddPassButton, context: Context) {
    // No dynamic updates needed
  }
}
