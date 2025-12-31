import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct DisabledCardListView: View {
  @StateObject private var viewModel: DisabledCardListViewModel
  @State private var cardHeight: CGFloat = 200
  
  init(cards: [CardModel]) {
    _viewModel = .init(wrappedValue: DisabledCardListViewModel(cards: cards))
  }
  
  var body: some View {
    VStack(spacing: 24) {
      cardsView
      closedTimeView
      Spacer()
    }
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.DisabledVirtualCards.Screen.title)
  }
}

extension DisabledCardListView {
  var cardsView: some View {
    ZStack(alignment: .top) {
      ForEach(Array($viewModel.cardsList.enumerated()), id: \.element.id) { index, $card in
        item(card: $card, index: index, showingItem: index == viewModel.cardsList.count - 1)
      }
    }
    .frame(maxWidth: .infinity, minHeight: calculatedCardsHeight, alignment: .top)
    .onPreferenceChange(CardHeightPreferenceKey.self) { height in
      cardHeight = height
    }
    .onChange(of: viewModel.currentCard) { _ in
      viewModel.isShowCardNumber = false
    }
  }
  
  func item(
    card: Binding<CardModel>,
    index: Int,
    showingItem: Bool
  ) -> some View {
    CardDetailItemView(
      cardModel: card,
      cardMetaData: card.metadata,
      isShowCardNumber: showingItem ? $viewModel.isShowCardNumber : .constant(false),
      isLoading: .constant(false),
      hasBlurView: !showingItem
    )
    .tag(card.id)
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
      viewModel.onCardItemTap(card: card.wrappedValue)
    }
  }
  
  @ViewBuilder
  var showCardNumberCell: some View {
    if viewModel.isShowingShowCardNumberCell {
      CardActionSwitchCell(
        title: L10N.Common.CardDetailsList.ShowCardNumber.title,
        icon: GenImages.Images.icoProfile.swiftUIImage,
        isOn: $viewModel.isShowCardNumber
      )
    }
  }
  
  @ViewBuilder
  var closedTimeView: some View {
    if let closedTime = viewModel.closedTime {
      Text(L10N.Common.CardDetailsList.Closed.time(closedTime))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundStyle(Colors.textSecondary.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
    }
  }
}

// MARK: Helpers
extension DisabledCardListView {
  private var calculatedCardsHeight: CGFloat {
    guard !viewModel.cardsList.isEmpty else { return cardHeight }
    let offsetSpacing: CGFloat = 42
    // Calculate total height: measured card height + offset for all cards except the first
    return cardHeight + (offsetSpacing * CGFloat(viewModel.cardsList.count - 1))
  }
}
