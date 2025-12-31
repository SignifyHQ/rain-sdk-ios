import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import RainFeature
import GeneralFeature

struct CashCardView: View {
  @StateObject private var viewModel: CashCardViewModel
  @Binding var isNotLinkedCard: Bool
  
  @ObservedObject var listCardViewModel: RainListCardsViewModel
  let isPOFlow: Bool
  let showLoadingIndicator: Bool
  let cashBalance: Double
  let assetType: AssetType
  let orderCardAction: () -> Void
  
  private var isCardAvailable: Bool {
    isPOFlow
  }
  
  private var cardImageAsset: Image {
    if listCardViewModel.hasFrntCard {
      return GenImages.Images.frntCard.swiftUIImage
    }
    
    return isCardAvailable && !isNotLinkedCard ? GenImages.Images.availableCard.swiftUIImage : GenImages.Images.unavailableCard.swiftUIImage
  }
  
  @State private var cardImageAssetID: String = ""

  init(
    isNoLinkedCard: Binding<Bool>,
    isPOFlow: Bool,
    showLoadingIndicator: Bool,
    cashBalance: Double,
    assetType: AssetType,
    listCardViewModel: RainListCardsViewModel,
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
          .transition(.opacity)
          .id(cardImageAssetID)
          .animation(.easeInOut(duration: 0.4), value: cardImageAssetID)
        
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
    .onChange(
      of: cardImageAsset,
      perform: { _ in
        let newId: String = {
          if listCardViewModel.hasFrntCard {
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
      RainListCardsView(viewModel: listCardViewModel)
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
            Text(L10N.Common.CashTab.CreateCard.buttonTitle)
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
        Text(L10N.Common.CashCard.Balance.title)
          .foregroundColor(listCardViewModel.hasFrntCard ? .black : Colors.contrast.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        ZStack(alignment: .bottomLeading) {
          if listCardViewModel.hasFrntCard {
            LottieView(loading: .contrast, tint: .black)
              .frame(width: 30, height: 20, alignment: .leading)
              .hidden(!showLoadingIndicator)
          } else {
            LottieView(loading: .contrast, tint: Colors.contrast.swiftUIColor.uiColor)
              .frame(width: 30, height: 20, alignment: .leading)
              .hidden(!showLoadingIndicator)
          }
          
          Text(
            cashBalance.formattedUSDAmount()
          )
          .foregroundColor(listCardViewModel.hasFrntCard ? .black : Colors.contrast.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: 22))
          .hidden(showLoadingIndicator)
        }
      }
      .padding([.leading, .bottom], 16)
      Spacer()
    }
  }
}
