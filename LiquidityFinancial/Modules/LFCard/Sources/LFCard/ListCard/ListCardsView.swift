import Combine
import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import LFRewards

public struct ListCardsView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: ListCardsViewModel
  @State private var activeContent: ActiveContent = .verifyCvv
  
  public init(viewModel: ListCardsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      if viewModel.isInit {
        loadingView
      } else {
        cardDetails
        pageIndicator
      }
    }
    .onChange(of: viewModel.currentCard) { _ in
      viewModel.onChangeCurrentCard()
    }
    .onDisappear {
      viewModel.onDisappear()
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
    .sheet(item: $viewModel.present) { item in
      switch item {
      case let .addAppleWallet(cardModel):
        AddAppleWalletView(card: cardModel, onFinish: {})
          .embedInNavigation()
      case let .applePay(cardModel):
        ApplePayViewController(card: cardModel)
      }
    }
    .fullScreenCover(item: $viewModel.fullScreenPresent) { item in
      switch item {
      case let .activatePhysicalCard(cardModel):
        ActivatePhysicalCardView(card: cardModel) { cardID in
          viewModel.activePhysicalSuccess(id: cardID)
        }
        .embedInNavigation()
      case let .changePin(card):
        changePinContent(cardID: card.id)
          .embedInNavigation()
      }
    }
    .popup(item: $viewModel.popup, dismissMethods: .tapInside) { item in
      switch item {
      case .confirmCloseCard:
        confirmationCloseCardPopup
      case .closeCardSuccessfully:
        closeCardSuccessfullyPopup
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .orderPhysicalCard:
        OrderPhysicalCardView(navigation: $viewModel.navigation) { card in
          viewModel.orderPhysicalSuccess(card: card)
        }
      }
    }
    .popup(isPresented: $viewModel.roundUpPurchasesPopup, content: {
      roundUpPurchasesPopup
    })
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
  }
}

// MARK: - View Components
private extension ListCardsView {
  func changePinContent(cardID: String) -> some View {
    Group {
      switch activeContent {
      case .verifyCvv:
        EnterCVVCodeView(cardID: cardID, screenTitle: LFLocalizable.EnterCVVCode.SetCardPin.title) { verifyID in
          activeContent = .changePin(verifyID)
        }
      case let .changePin(verifyID):
        SetCardPinView(verifyID: verifyID, cardID: cardID)
      }
    }
  }
  
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
    VStack(spacing: 16) {
      cardView
      rows
      Spacer()
      buttonGroup
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

  var cardView: some View {
    TabView(selection: $viewModel.currentCard) {
      ForEach(Array(viewModel.cardsList.enumerated()), id: \.element.id) { offset, item in
        CardView(
          card: item,
          cardMetaData: viewModel.cardMetaDatas.count > offset ? $viewModel.cardMetaDatas[offset] : .constant(nil),
          isShowCardNumber: $viewModel.isShowCardNumber,
          isLoading: $viewModel.isInit
        )
          .tag(item)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .padding(.top, 10)
    .frame(maxHeight: 220)
  }
  
  @ViewBuilder var pageIndicator: some View {
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
  
  @ViewBuilder
  var rows: some View {
    VStack(alignment: .leading, spacing: 18) {
      if viewModel.showRoundUpPurchases {
        roundUpPurchasesView
      }
      
      if viewModel.currentCard.cardType != .physical || viewModel.currentCard.cardStatus != .unactivated {
        Text(LFLocalizable.ListCard.Security.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      VStack(spacing: 16) {
        if viewModel.currentCard.cardType != .physical {
          row(
            title: LFLocalizable.ListCard.ShowCardNumber.title.localizedString,
            subtitle: nil,
            isSwitchOn: $viewModel.isShowCardNumber,
            onChange: nil
          )
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
        if viewModel.currentCard.cardStatus != .unactivated {
          row(
            title: LFLocalizable.ListCard.LockCard.title,
            subtitle: LFLocalizable.ListCard.LockCard.description,
            isSwitchOn: $viewModel.isCardLocked
          ) { _ in
            viewModel.lockCardToggled()
          }
        }
        if viewModel.isActive && viewModel.currentCard.cardType != .virtual {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          row(title: LFLocalizable.ListCard.ChangePin.title) {
            viewModel.onClickedChangePinButton()
          }
        }
        if viewModel.currentCard.cardStatus != .closed && viewModel.currentCard.cardStatus != .disabled {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          row(title: LFLocalizable.ListCard.CloseCard.title) {
            viewModel.onClickCloseCardButton()
          }
        }
      }
    }
    .padding(.top, 8)
  }
  
  func row(title: String, subtitle: String?, isSwitchOn: Binding<Bool>, onChange: ((Bool) -> Void)?) -> some View {
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
  
  func row(title: String, onTap: @escaping () -> Void) -> some View {
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
  
  @ViewBuilder var buttonGroup: some View {
    VStack(spacing: 14) {
      if viewModel.isActive {
        // applePay TODO: - Temporarily hide this button
        EmptyView()
      } else if viewModel.currentCard.cardStatus == .unactivated {
        activeCardButton
      }
      if !viewModel.isHasPhysicalCard {
        FullSizeButton(
          title: LFLocalizable.ListCard.OrderPhysicalCard.title,
          isDisable: false
        ) {
          viewModel.onClickedOrderPhysicalCard()
        }
      }
    }
  }
  
  var applePay: some View {
    Button {
      viewModel.onClickedAddToApplePay()
    } label: {
      ApplePayButton()
        .frame(height: 40)
        .cornerRadius(10)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Colors.label.swiftUIColor, lineWidth: 1)
        )
    }
  }
  
  var activeCardButton: some View {
    FullSizeButton(
      title: LFLocalizable.ListCard.ActivateCard.buttonTitle(viewModel.currentCard.cardType.title),
      isDisable: false
    ) {
      viewModel.onClickedActiveCard()
    }
  }
  
  var roundUpPurchasesView: some View {
    HStack(spacing: 12) {
      GenImages.CommonImages.icRoundUpDonationLeft.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      VStack(alignment: .leading, spacing: 2) {
        Text(LFLocalizable.CardsDetail.donations)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        
        Text(LFLocalizable.CardsDetail.Roundup.desc)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      Spacer()
      Button {
        viewModel.roundUpPurchasesPopup.toggle()
      } label: {
        GenImages.CommonImages.info.swiftUIImage
      }
      .foregroundColor(Colors.label.swiftUIColor)
      
      roundUpToggle
    }
    .padding(14)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  var roundUpToggle: some View {
    let isOn: Binding<Bool> = .init {
      viewModel.roundUpPurchases
    } set: { value in
      viewModel.callUpdateRoundUpDonationAPI(status: value)
    }
    return ZStack {
      Toggle("", isOn: isOn)
        .toggleStyle(SwitchToggleStyle(tint: Colors.primary.swiftUIColor))
        .frame(maxWidth: 36)
        .padding(.trailing, 12)
        .hidden(viewModel.isUpdatingRoundUpPurchases)

      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
        .hidden(!viewModel.isUpdatingRoundUpPurchases)
    }
  }

  var roundUpPurchasesPopup: some View {
    PopupAlert {
      VStack(spacing: 24) {
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .frame(width: 80, height: 80)

        Text(LFLocalizable.CardsDetail.Roundup.title)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(Colors.label.swiftUIColor)

        ShoppingGivesAlert(type: .roundUp)
          .frame(height: 300)

        FullSizeButton(title: LFLocalizable.Button.Ok.title, isDisable: false) {
          viewModel.roundUpPurchasesPopup = false
        }
      }
    }
  }
  
  var confirmationCloseCardPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.ListCard.CloseCard.title.uppercased(),
      message: LFLocalizable.ListCard.CloseCard.message,
      primary: .init(
        text: LFLocalizable.Button.Ok.title,
        action: {
          viewModel.closeCard()
        }
      ),
      secondary: .init(
        text: LFLocalizable.Button.NotNow.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
  
  var closeCardSuccessfullyPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.ListCard.CardClosed.title,
      message: LFLocalizable.ListCard.CardClosed.message,
      primary: .init(
        text: LFLocalizable.Button.Ok.title,
        action: {
          viewModel.primaryActionCloseCardSuccessfully {
            dismiss()
          }
        }
      )
    )
  }
}
// MARK: - View Types
private extension ListCardsView {
  enum ActiveContent {
    case verifyCvv
    case changePin(String)
  }
}
