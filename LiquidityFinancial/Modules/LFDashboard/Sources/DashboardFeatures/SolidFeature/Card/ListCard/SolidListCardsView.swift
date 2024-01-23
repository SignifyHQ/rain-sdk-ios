import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import LFRewards
import Services

public struct SolidListCardsView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  var viewModel: SolidListCardsViewModel
  
  public init(viewModel: SolidListCardsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      if viewModel.isInit {
        loadingView
      } else {
        content
      }
    }
    .onChange(of: viewModel.currentCard) { _ in
      viewModel.onChangeCurrentCard()
    }
    .onAppear {
      viewModel.onAppear()
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .navigationBarBackButtonHidden(true)
    .toolbar { toolbarContent }
    .overlay(cardsList.padding(.top, 8), alignment: .top)
    .onTapGesture {
      viewModel.isShowListCardDropdown = false
    }
    .sheet(item: $viewModel.sheet) { item in
      switch item {
      case let .applePay(destinationView):
        destinationView
      }
    }
    .fullScreenCover(item: $viewModel.fullScreen) { item in
      switch item {
      case let .activatePhysicalCard(destinationView):
        destinationView
          .embedInNavigation()
      case .changePin:
        SetCardPinView(
          viewModel: SolidSetCardPinViewModel(cardModel: viewModel.currentCard)
        )
        .embedInNavigation()
      }
    }
    .popup(item: $viewModel.popup, dismissMethods: .tapInside) { item in
      switch item {
      case .confirmCloseCard:
        confirmationCloseCardPopup
      case .closeCardSuccessfully:
        closeCardSuccessfullyPopup
      case .roundUpPurchases:
        roundUpPurchasesPopup
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - ToolBar Components
private extension SolidListCardsView {
  var toolbarContent: some ToolbarContent {
    Group {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          viewModel.resetActionShowCardNumber()
          dismiss()
        } label: {
          GenImages.CommonImages.icBack.swiftUIImage
        }
      }
      
      ToolbarItem(placement: .principal) {
        cardSwitchButton
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.openSupportScreen()
        } label: {
          GenImages.CommonImages.icChat.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
    }
  }
  
  var cardSwitchButton: some View {
    Button {
      viewModel.isShowListCardDropdown.toggle()
    } label: {
      HStack {
        Text(viewModel.title(for: viewModel.currentCard))
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Image(systemName: viewModel.isShowListCardDropdown ? "chevron.up" : "chevron.down")
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .frame(width: 172)
    .background(Colors.buttons.swiftUIColor.cornerRadius(16))
    .opacity(viewModel.cardsList.count > 1 ? 1 : 0)
  }
}

// MARK: - Content Components
private extension SolidListCardsView {
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(max: .infinity)
  }
  
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        card
        donationRows
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
  }
}

// MARK: - Top Components
private extension SolidListCardsView {
  @ViewBuilder
  var cardsList: some View {
    if viewModel.isShowListCardDropdown {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(viewModel.cardsList, id: \.id) { item in
          HStack {
            Text(viewModel.title(for: item))
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            Image(systemName: "checkmark")
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(viewModel.currentCard.id == item.id ? Colors.primary.swiftUIColor : .clear)
          }
          .frame(height: 14)
          .onTapGesture {
            viewModel.currentCard = item
            viewModel.isShowListCardDropdown.toggle()
          }
        }
      }
      .padding(16)
      .frame(width: 172)
      .background(Colors.buttons.swiftUIColor.cornerRadius(16))
    }
  }
  
  var card: some View {
    TabView(selection: $viewModel.currentCard) {
      ForEach([viewModel.currentCard], id: \.id) { item in
        SolidCardView(cardModel: item, isShowCardNumber: $viewModel.isShowCardNumber)
          .tag(item)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .padding(.top, 8)
    .frame(height: 260)
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
private extension SolidListCardsView {
  @ViewBuilder
  var donationRows: some View {
    VStack(alignment: .leading, spacing: 10) {
      if viewModel.showRoundUpPurchases {
        roundUpPurchasesView
      }
    }
    .padding(.top, -16)
  }
  
  @ViewBuilder
  var rows: some View {
    VStack(alignment: .leading, spacing: 18) {
      if viewModel.currentCard.cardStatus != .unactivated {
        Text(LFLocalizable.ListCard.Security.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      VStack(spacing: 16) {
        row(
          title: LFLocalizable.ListCard.ShowCardNumber.title.localizedString,
          subtitle: nil,
          isSwitchOn: $viewModel.isShowCardNumber,
          onChange: nil
        )
        
        if viewModel.currentCard.cardStatus != .unactivated {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          row(
            title: LFLocalizable.ListCard.LockCard.title,
            subtitle: LFLocalizable.ListCard.LockCard.description,
            isSwitchOn: $viewModel.isCardLocked
          ) { _ in
            viewModel.lockCardToggled()
          }
        }
        
        if viewModel.isActivePhysical {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          row(title: LFLocalizable.ListCard.ChangePin.title) {
            viewModel.onClickedChangePinButton()
          }
        }
        
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        row(title: LFLocalizable.ListCard.CloseCard.title) {
          viewModel.onClickCloseCardButton()
        }
        
        if let cardLimitModel = viewModel.cardLimitUIModel {
          GenImages.CommonImages.dash.swiftUIImage
          rowLabel(title: LFLocalizable.CardsDetail.monthlyLimits, subtitle: cardLimitModel.spendLimits)
          
          GenImages.CommonImages.dash.swiftUIImage
          rowLabel(title: LFLocalizable.CardsDetail.availableLimits, subtitle: cardLimitModel.availableLimits)
          
          GenImages.CommonImages.dash.swiftUIImage
          rowLabel(title: LFLocalizable.CardsDetail.perTransactionLimits, subtitle: cardLimitModel.transactionLimits)
        }
      }
    }
    .padding(.top, 8)
    .padding(.trailing, 4)
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
  
  func rowLabel(title: String, subtitle: String) -> some View {
    HStack {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      Text(subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
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
        viewModel.onClickedRoundUpPurchasesInformation()
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
}

// MARK: - Bottom Components
private extension SolidListCardsView {
  @ViewBuilder var buttonGroup: some View {
    VStack(spacing: 14) {
      if viewModel.isActivePhysical {
        // applePay TODO: - Temporarily hide this button because Solid doesn't support
      } else if viewModel.currentCard.cardStatus == .unactivated {
        activeCardButton
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
      isDisable: false,
      isLoading: $viewModel.isActivatingCard
    ) {
      viewModel.activePhysicalCard(
        activeCardView: AnyView(
          SolidActivePhysicalCardView(card: viewModel.currentCard)
        )
      )
    }
  }
}

// MARK: - Popup
private extension SolidListCardsView {
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
          viewModel.hidePopup()
        }
      }
    }
  }
}
