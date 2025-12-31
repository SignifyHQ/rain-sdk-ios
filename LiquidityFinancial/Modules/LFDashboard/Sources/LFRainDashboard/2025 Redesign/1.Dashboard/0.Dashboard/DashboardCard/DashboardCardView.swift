import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import RainFeature
import GeneralFeature

struct DashboardCardView: View {
  @StateObject private var viewModel: DashboardCardViewModel
  @Binding var isNotLinkedCard: Bool
  
  @ObservedObject var cardDetailsListViewModel: CardDetailsListViewModel
  let isPOFlow: Bool
  let showLoadingIndicator: Bool
  let cashBalance: Double
  let assetType: AssetType
  let orderCardAction: () -> Void
  
  private var isCardAvailable: Bool {
    isPOFlow
  }
  
  private var cardImageAsset: Image {
    if cardDetailsListViewModel.hasFrntCard {
      return GenImages.Images.frntCard.swiftUIImage
    }
    
    return isCardAvailable && !isNotLinkedCard ? GenImages.Images.visaCardBackdrop.swiftUIImage : GenImages.Images.unavailableVisaCardBackdrop.swiftUIImage
  }
  
  @State private var cardImageAssetID: String = ""

  init(
    isNoLinkedCard: Binding<Bool>,
    isPOFlow: Bool,
    showLoadingIndicator: Bool,
    cashBalance: Double,
    assetType: AssetType,
    cardDetailsListViewModel: CardDetailsListViewModel,
    orderCardAction: @escaping () -> Void
  ) {
    _isNotLinkedCard = isNoLinkedCard
    self.isPOFlow = isPOFlow
    self.cashBalance = cashBalance
    self.assetType = assetType
    self.showLoadingIndicator = showLoadingIndicator
    self.orderCardAction = orderCardAction
    self.cardDetailsListViewModel = cardDetailsListViewModel
    _viewModel = .init(wrappedValue: DashboardCardViewModel())
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .bottomLeading) {
        cardImageAsset
          .resizable()
          .background(Color.clear)
          .clipped()
          .aspectRatio(contentMode: .fit)
          .transition(.opacity)
          .id(cardImageAssetID)
          .animation(.easeInOut(duration: 0.4), value: cardImageAssetID)
        
        createCardButton
      }
      
      if isPOFlow && !isNotLinkedCard {
        viewCardButton
        balance
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .onReceive(NotificationCenter.default.publisher(for: .noLinkedCards)) { _ in
      isNotLinkedCard = true
    }
    .onReceive(NotificationCenter.default.publisher(for: .createdCard)) { _ in
      isNotLinkedCard = false
    }
    .onChange(
      of: cardImageAsset,
      perform: { _ in
        let newId: String = {
          if cardDetailsListViewModel.hasFrntCard {
            return "wyoming"
          }
          
          return isCardAvailable && !isNotLinkedCard ? "available" : "unavailable"
        }()
        
        withAnimation {
          cardImageAssetID = newId
        }
      }
    )
    .navigationLink(isActive: $viewModel.isShowCardDetail) {
      CardDetailsListView(viewModel: cardDetailsListViewModel)
    }
  }
}

extension DashboardCardView {
  @ViewBuilder private var createCardButton: some View {
    if isNotLinkedCard {
      FullWidthButton(
        type: .secondary,
        height: 40,
        title: L10N.Common.CashTab.CreateCard.buttonTitle,
        isDisabled: viewModel.isCreatingCard,
        isLoading: $viewModel.isCreatingCard
      ) {
        viewModel.createCard(onSuccess: {
          isNotLinkedCard = false
        })
      }
      .padding([.horizontal, .bottom], 8)
    }
  }
  
  var viewCardButton: some View {
    VStack {
      HStack {
        Spacer()
        
        FullWidthButton(
          type: .secondary,
          height: 24,
          tintColor: cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor,
          borderColor: cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor,
          title: L10N.Common.Dashboard.Card.ViewCard.title,
          font: Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value),
          isDisabled: viewModel.isCreatingCard,
          isLoading: $viewModel.isCreatingCard,
          titlePadding: 8
        ) {
          viewModel.isShowCardDetail.toggle()
        }
        .frame(width: 80)
        .padding([.top, .trailing], 12)
      }
      
      Spacer()
    }
  }
  
  var balance: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(L10N.Common.Dashboard.Card.Balance.title)
          .foregroundColor(cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        ZStack(alignment: .bottomLeading) {
          DefaultLottieView(
            loading: .branded,
            tint: UIColor(cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor)
          )
          .frame(width: 24, height: 24, alignment: .leading)
          .hidden(!showLoadingIndicator)
          
          Text(cashBalance.formattedUSDAmount())
            .foregroundColor(cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.custom(size: 22).value))
            .hidden(showLoadingIndicator)
        }
      }
      .padding([.leading, .bottom], 12)
      Spacer()
    }
  }
}
