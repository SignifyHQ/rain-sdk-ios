import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct DisabledCardListView: View {
  @StateObject private var viewModel: DisabledCardListViewModel
  
  @State private var cardHeight: CGFloat = 200
  
  init(
    cards: [CardModel]
  ) {
    _viewModel = .init(wrappedValue: DisabledCardListViewModel(cards: cards))
  }
  
  var body: some View {
    ScrollView {
      VStack(
        spacing: 24
      ) {
        cardsView
        closedTimeView
        usedCardsView
        
        Spacer()
      }
      .padding(.top, 8)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
    }
    .background(Colors.baseAppBackground2.swiftUIColor)
    .scrollIndicators(.hidden)
    .appNavBar(navigationTitle: L10N.Common.DisabledVirtualCards.Screen.title)
  }
}

// MARK: - View Components
extension DisabledCardListView {
  var cardsView: some View {
    ZStack(
      alignment: .top
    ) {
      ForEach(
        Array($viewModel.closedVirtualCardsList.enumerated()),
        id: \.element.id
      ) { index, $card in
        item(
          card: $card,
          index: index,
          showingItem: index == viewModel.closedVirtualCardsList.count - 1
        )
      }
    }
    .frame(
      maxWidth: .infinity,
      minHeight: calculatedCardsHeight,
      alignment: .top
    )
    .onPreferenceChange(CardHeightPreferenceKey.self) { height in
      cardHeight = height
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
      isShowCardNumber: .constant(false),
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
      withAnimation(
        .spring(
          response: 0.4,
          dampingFraction: 0.75
        )
      ) {
        viewModel.onCardItemTap(card: card.wrappedValue)
      }
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
  
  @ViewBuilder
  var usedCardsView: some View {
    HStack(
      alignment: .top,
      spacing: 12
    ) {
      (
        viewModel.hasReachedCardLimit
        ? GenImages.Images.icoWarningRed
        : GenImages.Images.icoWarningBlue
      )
      .swiftUIImage
      .resizable()
      .frame(32)
      
      Text(
        viewModel.hasReachedCardLimit
        ? L10N.Common.CardDetailsList.UsedCards.NotAvailable.title(Constants.virtualCardCountLimit, Constants.virtualCardCountLimit)
        : L10N.Common.CardDetailsList.UsedCards.Available.title(viewModel.usedCardCount, Constants.virtualCardCountLimit, viewModel.remainingCardCount)
      )
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundStyle(Colors.textTertiary.swiftUIColor)
      .multilineTextAlignment(.leading)
    }
  }
}

// MARK: Helper Functions
extension DisabledCardListView {
  private var calculatedCardsHeight: CGFloat {
    guard !viewModel.closedVirtualCardsList.isEmpty
    else {
      return cardHeight
    }
    
    let offsetSpacing: CGFloat = 42
    // Calculate total height: measured card height + offset for all cards except the first
    return cardHeight + (offsetSpacing * CGFloat(viewModel.closedVirtualCardsList.count - 1))
  }
}
