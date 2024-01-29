import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import GeneralFeature

struct CardDetailView: View {
  @Environment(\.dismiss)
  private var dismiss
  
  @StateObject
  private var viewModel: CardDetailViewModel
  
  init(viewModel: CardDetailViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - ToolBar View Components
private extension CardDetailView {
  var toolbarContent: some ToolbarContent {
    Group {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          GenImages.CommonImages.icBack.swiftUIImage
        }
      }
      
      ToolbarItem(placement: .principal) {
        switchCardButton
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
  
  @ViewBuilder
  var switchCardButton: some View {
    if viewModel.cardsList.count > 1 {
      Button {
        viewModel.isShowListCardDropdown.toggle()
      } label: {
        HStack {
          Text(viewModel.currentCard.titleWithTheLastFourDigits)
          Spacer()
            .frame(minWidth: 4, maxWidth: 28)
          GenImages.CommonImages.icArrowDown.swiftUIImage
            .rotationEffect(
              .degrees(viewModel.isShowListCardDropdown ? 180 : 0)
            )
        }
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.horizontal, 4)
        .frame(width: 168, height: 32)
        .background(
          Colors.buttons.swiftUIColor.cornerRadius(32)
        )
      }
    }
  }
  
  @ViewBuilder
  var cardDropdownListView: some View {
    if viewModel.isShowListCardDropdown {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(viewModel.cardsList, id: \.id) { card in
          HStack {
            Text(card.titleWithTheLastFourDigits)
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            GenImages.CommonImages.icCheckmark.swiftUIImage
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(viewModel.currentCard.id == card.id ? Colors.primary.swiftUIColor : .clear)
          }
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .frame(height: 14)
          .onTapGesture {
            viewModel.onSwitchedCard(to: card)
          }
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .frame(width: 168)
      .background(
        Colors.buttons.swiftUIColor.cornerRadius(16)
      )
      .padding(.top, 8)
    }
  }
}

// MARK: - View Components
private extension CardDetailView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 24) {
        cardView
        cardConfigurationsView
        transactionListView
      }
    }
    .padding(.top, 24)
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .navigationBarBackButtonHidden(true)
    .toolbar { toolbarContent }
    .overlay(cardDropdownListView, alignment: .top)
    .overlay { apiLoadingView }
    .disabled(viewModel.isCallingAPI)
  }
  
  @ViewBuilder
  var apiLoadingView: some View {
    if viewModel.isCallingAPI {
      ProgressView().progressViewStyle(.circular)
        .tint(Colors.primary.swiftUIColor)
    }
  }
  
  var cardView: some View {
    TabView(selection: $viewModel.currentCard) {
      ForEach([viewModel.currentCard], id: \.id) { item in
        VGSCardView(card: $viewModel.currentCard)
          .tag(item)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .frame(height: 192)
  }
  
  var cardConfigurationsView: some View {
    VStack(spacing: 16) {
      makeCardConfigurationCell(
        title: L10N.Common.Card.CardType.title,
        value: viewModel.currentCard.cardType.title
      )
      makeCardConfigurationCell(
        title: L10N.Common.Card.CardName.title,
        value: viewModel.currentCard.cardName
      ) {
        viewModel.navigateToEditCardName()
      }
      iconButtonGroup
    }
  }
  
  var transactionListView: some View {
    ShortTransactionsView(
      transactions: $viewModel.transactionsList,
      title: L10N.Common.Card.LatestTransaction.title,
      onTapTransactionCell: viewModel.onClickedTransactionRow,
      seeAllAction: {
        viewModel.onClickedSeeAllButton()
      }
    )
  }
  
  func makeCardConfigurationCell(title: String, value: String, action: (() -> Void)? = nil) -> some View {
    VStack(spacing: 16) {
      HStack {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        Spacer()
        Text(value)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .lineLimit(1 )
      }
      GenImages.CommonImages.dash.swiftUIImage
    }
    .foregroundColor(Colors.label.swiftUIColor)
    .onTapGesture {
      guard viewModel.isCardClosed else {
        action?()
        return
      }
    }
  }
  
  @ViewBuilder
  var iconButtonGroup: some View {
    if !viewModel.isCardClosed {
      HStack(spacing: 40) {
        GenImages.CommonImages.icTrash.swiftUIImage
          .resizable()
          .frame(24)
          .foregroundColor(Colors.error.swiftUIColor)
          .onTapGesture {
            viewModel.onClickedTrashButton()
          }
        if viewModel.currentCard.cardStatus != .unactivated {
          viewModel.spendingStatusIcon.swiftUIImage
            .resizable()
            .frame(24)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
            .onTapGesture {
              viewModel.updateCardSpendingStatus()
            }
        }
      }
    }
  }
}
