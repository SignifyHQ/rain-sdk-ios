import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct CardsTabView: View {
  @StateObject
  private var viewModel: CardsTabViewModel
  
  init() {
    let cardsTabViewModel = CardsTabViewModel()
    _viewModel = .init(wrappedValue: cardsTabViewModel)
  }
  
  var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 32) {
        makeHeaderTabView(width: proxy.size.width - 60)
        mainContent
        Spacer()
      }
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case let .cardDetail(viewModel):
        CardDetailView(viewModel: viewModel)
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .padding(.top, 24)
    .padding(.bottom, 16)
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
                  colors: [.clear, Colors.label.swiftUIColor.opacity(0.1)],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
              .allowsHitTesting(false)
          }
        }
      }
    }
    .refreshable {
      viewModel.refresh()
    }
  }
}

#Preview {
  CardsTabView()
}
