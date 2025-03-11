import Combine
import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct RainListCardsView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: RainListCardsViewModel
  
  public init(viewModel: RainListCardsViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      if viewModel.isInit {
        loadingView
      } else {
        cardDetails
      }
    }
    .onChange(of: viewModel.currentCard) { _ in
      viewModel.onChangeCurrentCard()
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(
      icon: .support,
      navigationTitle: "",
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .overlay(
      cardsList.padding(.top, 8),
      alignment: .top
    )
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
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case let .orderPhysicalCard(destinationView):
        destinationView
      case .creditLimitBreakdown:
        CreditLimitBreakdownView(
          viewModel: CreditLimitBreakdownViewModel()
        )
      }
    }
    .popup(item: $viewModel.popup, dismissMethods: .tapInside) { item in
      switch item {
      case .confirmCloseCard:
        confirmationCloseCardPopup
      case .closeCardSuccessfully:
        closeCardSuccessfullyPopup
      default: EmptyView()
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
private extension RainListCardsView {
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
    .frame(width: 180)
    .background(Colors.buttons.swiftUIColor.cornerRadius(16))
    .opacity(viewModel.cardsList.count > 1 ? 1 : 0)
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
    VStack(spacing: 16) {
      card
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

// MARK: - Top Components
private extension RainListCardsView {
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
      .padding(.horizontal, 8)
      .padding(.vertical, 16)
      .frame(width: 180)
      .background(Colors.buttons.swiftUIColor.cornerRadius(16))
    }
  }
  
  var card: some View {
    TabView(selection: $viewModel.currentCard) {
      ForEach(Array(viewModel.cardsList.enumerated()), id: \.element.id) { offset, item in
        RainCardView(
          cardModel: item,
          cardMetaData: viewModel.cardMetaDatas.count > offset ? $viewModel.cardMetaDatas[offset] : .constant(nil),
          isShowCardNumber: $viewModel.isShowCardNumber,
          isLoading: $viewModel.isInit
        )
        .tag(item)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .padding(.top, 24)
    .frame(maxHeight: 260)
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
    VStack(alignment: .leading, spacing: 18) {
      if viewModel.currentCard.cardType != .physical || viewModel.currentCard.cardStatus != .unactivated {
        Text(L10N.Common.ListCard.Security.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      VStack(spacing: 16) {
        if viewModel.currentCard.cardType != .physical {
          row(
            title: L10N.Common.ListCard.ShowCardNumber.title.localizedString,
            subtitle: nil,
            isSwitchOn: $viewModel.isShowCardNumber,
            onChange: nil
          )
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
        
        if viewModel.currentCard.cardStatus != .unactivated {
          row(
            title: L10N.Common.ListCard.LockCard.title,
            subtitle: L10N.Common.ListCard.LockCard.description,
            isSwitchOn: $viewModel.isCardLocked
          ) { _ in
            viewModel.lockCardToggled()
          }
        }
        
        if viewModel.currentCard.cardStatus != .closed && viewModel.currentCard.cardStatus != .disabled {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          row(title: L10N.Common.ListCard.CloseCard.title) {
            viewModel.onTapCloseCard()
          }
        }
        
//        GenImages.CommonImages.dash.swiftUIImage
//          .foregroundColor(Colors.label.swiftUIColor)
//        row(title: L10N.Common.ListCard.CreditLimitBreakdown.title) {
//          viewModel.onTapViewCreditLimitBreakdown()
//        }
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
}

// MARK: - Bottom Components
private extension RainListCardsView {
  @ViewBuilder var buttonGroup: some View {
    VStack(spacing: 14) {
      if viewModel.isActivePhysical {
        // applePay TODO: - Temporarily hide this button because NetSpend doesn't support
        EmptyView()
      } else if viewModel.currentCard.cardStatus == .unactivated {
        activeCardButton
      }
      
      // Hiding the button to order physical card temporarily
//      if !viewModel.isHasPhysicalCard {
//        FullSizeButton(
//          title: L10N.Common.ListCard.OrderPhysicalCard.title,
//          isDisable: false
//        ) {
//          viewModel.onTapOrderPhysicalCard()
//        }
//      }
    }
  }
  
  var applePay: some View {
    Button {
      viewModel.onTapAddToApplePay()
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
}

// MARK: - Popup
private extension RainListCardsView {
  var confirmationCloseCardPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ListCard.CloseCard.title.uppercased(),
      message: L10N.Common.ListCard.CloseCard.message,
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.closeCard()
        }
      ),
      secondary: .init(
        text: L10N.Common.Button.NotNow.title,
        action: {
          viewModel.hidePopup()
        }
      )
    )
  }
  
  var closeCardSuccessfullyPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ListCard.CardClosed.title,
      message: L10N.Common.ListCard.CardClosed.message,
      primary: .init(
        text: L10N.Common.Button.Ok.title,
        action: {
          viewModel.primaryActionCloseCardSuccessfully {
            dismiss()
          }
        }
      )
    )
  }
}
