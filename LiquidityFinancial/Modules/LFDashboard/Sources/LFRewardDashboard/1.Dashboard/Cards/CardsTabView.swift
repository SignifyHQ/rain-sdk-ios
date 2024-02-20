import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SolidFeature

public struct CardsTabView: View {
  @StateObject
  private var viewModel: CardsTabViewModel
  @Binding var cardsList: [CardModel]
  @Binding var isOpenCardsTab: Bool
  
  private var title: String = ""
  
  public init(
    cardsList: Binding<[CardModel]> = .constant([]),
    isOpenCardsTab: Binding<Bool> = .constant(false),
    title: String = ""
  ) {
    let cardsTabViewModel = CardsTabViewModel()
    _viewModel = .init(wrappedValue: cardsTabViewModel)
    _cardsList = cardsList
    _isOpenCardsTab = isOpenCardsTab
    self.title = title
  }
  
  public var body: some View {
    GeometryReader { proxy in
      VStack {
        makeHeaderTabView(width: proxy.size.width - 60)
        mainContent
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case let .cardDetail(viewModel):
        CardDetailView(viewModel: viewModel)
      case let .cardListDetail(viewModel):
        SolidListCardsView(viewModel: viewModel)
      case .createCard:
        CreateCardView(viewModel: CreateCardViewModel())
      }
    }
    .onChange(of: viewModel.selectedTab) { _ in
      isOpenCardsTab = viewModel.selectedTab == .open
    }
    .onChange(of: viewModel.cardsList) { cards in
      cardsList = cards
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .padding(.top, 24)
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension CardsTabView {
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
  }
  
  var mainContent: some View {
    Group {
      switch viewModel.status {
      case .idle:
        loadingView
      case let .success(filterredCards):
        makeListCardView(filterredCards: filterredCards)
      case .loading, .failure:
        EmptyView()
      }
    }
  }
  
  func makeHeaderTabView(width: CGFloat) -> some View {
    HStack(spacing: 0) {
      ForEach(viewModel.cardListType, id: \.self) { type in
        makeTabItem(type: type, width: (width - 8) / 2)
      }
    }
    .padding(.horizontal, 8)
    .frame(width: width, height: 40)
    .background(Colors.buttons.swiftUIColor)
    .cornerRadius(32)
    .padding(.horizontal, 30)
  }
  
  func makeTabItem(type: CardListType, width: CGFloat) -> some View {
    HStack {
      Spacer()
      Text(type.title)
        .foregroundColor(
          viewModel.selectedTab == type ? Colors.contrast.swiftUIColor : Colors.label.swiftUIColor
        )
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      Spacer()
    }
    .contentShape(Rectangle())
    .onTapGesture {
      Haptic.impact(.light).generate()
      viewModel.selectedTab = type
    }
    .frame(width: width, height: 32)
    .background(
      viewModel.selectedTab == type ? Colors.darkText.swiftUIColor : .clear
    )
    .cornerRadius(32)
  }
  
  func makeListCardView(filterredCards: [CardModel]) -> some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 20) {
        if filterredCards.isEmpty {
          noCardYetView
        } else {
          ForEach(filterredCards) { card in
            Button {
              viewModel.navigateToCardDetail(card: card, filterredCards: filterredCards)
            } label: {
              CardCellView(cardModel: card)
                .padding(.horizontal, 30)
            }
            .overlay(alignment: .bottom) {
              Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(
                  LinearGradient(
                    colors: [.clear, Colors.label.swiftUIColor.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                  )
                )
                .allowsHitTesting(false)
            }
          }
          .padding(.bottom, 4)
        }
        createNewCardButton
      }
      .padding(.top, 32)
      .padding(.bottom, 16)
    }
    .refreshable {
      viewModel.refresh()
    }
  }
  
  var noCardYetView: some View {
    VStack {
      Spacer()
        .frame(minHeight: UIScreen.main.bounds.size.height * 0.12)
      HStack {
        Spacer()
        VStack(spacing: 8) {
          GenImages.CommonImages.icSearch.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          Text(viewModel.noCardTitle)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
        Spacer()
      }
      Spacer()
        .frame(minHeight: UIScreen.main.bounds.size.height * 0.12)
    }
  }
  
  @ViewBuilder
  var createNewCardButton: some View {
    if viewModel.selectedTab == .open {
      FullSizeButton(
        title: L10N.Common.Card.CreateNewCard.title,
        isDisable: false,
        type: .secondary,
        icon: GenImages.CommonImages.icNewCard.swiftUIImage
      ) {
        viewModel.onClickedCreateNewCardButton()
      }
      .padding(.horizontal, 30)
    }
  }
}

#Preview {
  CardsTabView()
}
