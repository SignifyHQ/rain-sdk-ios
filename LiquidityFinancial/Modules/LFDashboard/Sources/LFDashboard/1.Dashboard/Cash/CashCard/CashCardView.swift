import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFCard
import BaseDashboard

struct CashCardView: View {
  @StateObject private var viewModel: CashCardViewModel
  @Binding var isNotLinkedCard: Bool
  
  let listCardViewModel: ListCardsViewModel
  let isPOFlow: Bool
  let showLoadingIndicator: Bool
  let cashBalance: Double
  let assetType: AssetType
  let orderCardAction: () -> Void
  
  private var isCardAvailable: Bool {
    isPOFlow
  }
  private var cardImageAsset: Image {
    isCardAvailable && !isNotLinkedCard ? GenImages.Images.availableCard.swiftUIImage : GenImages.Images.unavailableCard.swiftUIImage
  }

  init(
    isNoLinkedCard: Binding<Bool>,
    isPOFlow: Bool,
    showLoadingIndicator: Bool,
    cashBalance: Double,
    assetType: AssetType,
    listCardViewModel: ListCardsViewModel,
    orderCardAction: @escaping () -> Void
  ) {
    _isNotLinkedCard = isNoLinkedCard
    self.isPOFlow = isPOFlow
    self.cashBalance = cashBalance
    self.assetType = assetType
    self.showLoadingIndicator = showLoadingIndicator
    self.orderCardAction = orderCardAction
    self.listCardViewModel = listCardViewModel
    _viewModel = .init(wrappedValue: CashCardViewModel())
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .bottomLeading) {
        cardImageAsset
          .resizable()
          .background(Color.clear)
          .clipped()
          .aspectRatio(contentMode: .fit)
        createCardButton
      }
      if isPOFlow && !isNotLinkedCard {
        balance
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .onReceive(NotificationCenter.default.publisher(for: .noLinkedCards)) { _ in
      isNotLinkedCard = true
    }
    .onTapGesture {
      if isPOFlow && !isNotLinkedCard {
        viewModel.isShowCardDetail.toggle()
      }
    }
    .fullScreenCover(item: $viewModel.cardActivated) { card in
      activateCard(card: card)
    }
    .navigationLink(isActive: $viewModel.isShowCardDetail) {
      ListCardsView(viewModel: listCardViewModel)
    }
  }
  
  @ViewBuilder func activateCard(card: CardModel) -> some View {
    if card.cardType == .physical {
      ActivatePhysicalCardView(card: card)
        .embedInNavigation()
    }
  }

  @ViewBuilder private var createCardButton: some View {
    if isNotLinkedCard {
      Button {
        viewModel.createCard(onSuccess: {
          isNotLinkedCard = false
        })
      } label: {
        if viewModel.isCreatingCard {
          HStack {
            Spacer()
            CircleIndicatorView()
            Spacer()
          }
        } else {
          HStack {
            Spacer()
            Text(LFLocalizable.CashTab.CreateCard.buttonTitle)
              .foregroundColor(Colors.whiteText.swiftUIColor)
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
            Spacer()
          }
        }
      }
      .frame(height: 40)
      .background(Colors.buttons.swiftUIColor.cornerRadius(10))
      .padding([.horizontal, .bottom], 8)
    }
  }
  
  private var balance: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(LFLocalizable.CashCard.Balance.title(assetType.title))
          .foregroundColor(Colors.contrast.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        ZStack(alignment: .bottomLeading) {
          LottieView(loading: .contrast)
            .frame(width: 30, height: 20, alignment: .leading)
            .hidden(!showLoadingIndicator)
            .foregroundColor(Colors.contrast.swiftUIColor)
          Text(
            cashBalance.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
          )
            .foregroundColor(Colors.contrast.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: 22))
            .hidden(showLoadingIndicator)
        }
      }
      .padding([.leading, .bottom], 16)
      Spacer()
    }
  }
}
