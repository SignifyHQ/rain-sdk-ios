import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFCard

struct CashCardView: View {
  @StateObject private var viewModel: CashCardViewModel
  @Binding var cardDetails: CardModel
  let isPOFlow: Bool
  let showLoadingIndicator: Bool
  let cashBalance: Double
  let assetType: AssetType
  let orderCardAction: () -> Void
  
  private var isCardAvailable: Bool {
    isPOFlow
  }
  private var cardImageAsset: ImageAsset {
    isCardAvailable ? GenImages.Images.availableCard : GenImages.Images.unavailableCard
  }

  init(
    isPOFlow: Bool,
    showLoadingIndicator: Bool,
    cashBalance: Double,
    assetType: AssetType,
    cardDetails: Binding<CardModel>,
    orderCardAction: @escaping () -> Void
  ) {
    self.isPOFlow = isPOFlow
    self.cashBalance = cashBalance
    self.assetType = assetType
    self.showLoadingIndicator = showLoadingIndicator
    _cardDetails = cardDetails
    self.orderCardAction = orderCardAction
    _viewModel = .init(wrappedValue: CashCardViewModel(cardDetails: cardDetails.wrappedValue))
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .topTrailing) {
        cardImageAsset.swiftUIImage
          .resizable()
          .background(Color.clear)
          .clipped()
          .aspectRatio(contentMode: .fit)
        
        if cardDetails.cardStatus == .unactivated {
          activateCard
        }
      }
      if isPOFlow {
        balance
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .onTapGesture {
      if isPOFlow {
        if cardDetails.cardStatus == .unactivated {
          viewModel.activeCard()
        } else {
          viewModel.isShowCardDetail.toggle()
        }
      }
    }
    .fullScreenCover(item: $viewModel.cardActivated) { card in
      activateCard(card: card)
    }
    .navigationLink(isActive: $viewModel.isShowCardDetail) {
      ListCardsView()
    }
  }
  
  @ViewBuilder func activateCard(card: CardModel) -> some View {
    if card.cardType == .physical {
      ActivatePhysicalCardView(card: card)
        .embedInNavigation()
    }
  }

  private var activateCard: some View {
    FullSizeButton(
      title: LFLocalizable.CashTab.ActiveCard.buttonTitle(cardDetails.cardType.title),
      isDisable: false,
      type: .contrast,
      fontSize: Constants.FontSize.ultraSmall.value,
      height: 25,
      cornerRadius: 5,
      textColor: Colors.contrast.swiftUIColor,
      backgroundColor: Colors.buttons.swiftUIColor
    ) {
      viewModel.activeCard()
    }
    .padding([.horizontal, .top], 15)
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
