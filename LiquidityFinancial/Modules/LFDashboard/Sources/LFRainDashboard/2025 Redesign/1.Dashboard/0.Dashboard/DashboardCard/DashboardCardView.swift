import GeneralFeature
import LFLocalizable
import LFStyleGuide
import LFUtilities
import RainFeature
import SwiftTooltip
import SwiftUI

struct DashboardCardView: View {
  @ObservedObject var cardDetailsListViewModel: CardDetailsListViewModel
  
  @StateObject private var viewModel: DashboardCardViewModel
  
  @State private var cardImageAssetID: String = ""
  
  let isLoading: Bool
  let cashBalance: Double
  let orderCardAction: (() -> Void)?
  
  private var shouldShowEmptyState: Bool {
    cardDetailsListViewModel.shouldShowEmptyStateOnHome
  }
  
  private var hasExhausedCardLimit: Bool {
    cardDetailsListViewModel.isFinalVirtualCard && !cardDetailsListViewModel.isPhysicalCardOrderAvailable
  }
  
  private var cardImageAsset: Image {
    if cardDetailsListViewModel.hasFrntCard {
      return GenImages.Images.frntCard.swiftUIImage
    }
    
    return shouldShowEmptyState ? GenImages.Images.imgNoActiveCardBackdrop.swiftUIImage : GenImages.Images.visaCardBackdrop.swiftUIImage
  }
  
  init(
    viewModel: DashboardCardViewModel,
    cardDetailsListViewModel: CardDetailsListViewModel,
    cashBalance: Double,
    isLoading: Bool,
    orderCardAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    
    self.cardDetailsListViewModel = cardDetailsListViewModel
    self.cashBalance = cashBalance
    self.isLoading = isLoading
    self.orderCardAction = orderCardAction
  }
  
  var body: some View {
    ZStack(
      alignment: .bottom
    ) {
      ZStack(
        alignment: .bottomLeading
      ) {
        cardImageAsset
          .resizable()
          .background(Color.clear)
          .clipped()
          .aspectRatio(
            contentMode: .fit
          )
          .transition(.opacity)
          .id(cardImageAssetID)
          .animation(
            .easeInOut(
              duration: 0.4
            ),
            value: cardImageAssetID
          )
      }
      
      viewCardButton
      
      balanceView
    }
    .fixedSize(
      horizontal: false,
      vertical: true
    )
    .onChange(
      of: cardImageAsset
    ) { _, _ in
      let newId: String = {
        if cardDetailsListViewModel.hasFrntCard {
          return "wyoming"
        }
        
        return shouldShowEmptyState ? "unavailable" : "available"
      }()
      
      withAnimation {
        cardImageAssetID = newId
      }
    }
    .navigationLink(
      isActive: $viewModel.isShowCardDetail
    ) {
      CardDetailsListView(
        viewModel: cardDetailsListViewModel
      )
    }
  }
}

// MARK: - View Components
extension DashboardCardView {
  var viewCardButton: some View {
    VStack {
      HStack {
        Spacer()
        
        FullWidthButton(
          type: .secondary,
          height: 24,
          tintColor: cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor,
          borderColor: cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor,
          title: shouldShowEmptyState ? L10N.Common.Dashboard.Card.ViewCard.NoCard.title : L10N.Common.Dashboard.Card.ViewCard.title,
          font: Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value),
          isDisabled: viewModel.isCreatingCard,
          isLoading: $viewModel.isCreatingCard,
          titlePadding: 8
        ) {
          viewModel.isShowCardDetail.toggle()
        }
        .frame(
          width: 90
        )
        .padding([.top, .trailing], 12)
      }
      
      Spacer()
    }
  }
  
  var balanceView: some View {
    HStack {
      VStack(
        alignment: .leading,
        spacing: 2
      ) {
        HStack(
          spacing: 0
        ) {
          Text(shouldShowEmptyState ? L10N.Common.Dashboard.Card.Balance.NoCard.title : L10N.Common.Dashboard.Card.Balance.title)
            .foregroundColor(cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          
          if shouldShowEmptyState {
            Button {
              viewModel.isNoCardTooltipShown.toggle()
            } label: {
              GenImages.Images.icoSupport.swiftUIImage
                .resizable()
                .frame(24)
            }
            .tooltip(
              text: hasExhausedCardLimit ? L10N.Common.Dashboard.Card.Balance.NoCard.Exhausted.Disclousure.body : L10N.Common.Dashboard.Card.Balance.NoCard.Disclousure.body,
              isPresented: $viewModel.isNoCardTooltipShown,
              pointerPosition: .bottomCenter,
              config: toolTipConfiguration()
            )
          }
        }
        
        ZStack(
          alignment: .bottomLeading
        ) {
          DefaultLottieView(
            loading: .branded,
            tint: UIColor(cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor)
          )
          .frame(
            width: 24,
            height: 24,
            alignment: .leading
          )
          .hidden(!isLoading)
          
          Text(cashBalance.formattedUSDAmount())
            .foregroundColor(cardDetailsListViewModel.hasFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.custom(size: 22).value))
            .hidden(isLoading)
        }
      }
      .padding([.leading, .bottom], 12)
      
      Spacer()
    }
  }
}

// MARK: - Helper Methods
extension DashboardCardView {
  private func toolTipConfiguration(
  ) -> SwiftTooltip.Configuration {
    SwiftTooltip.Configuration(
      textColor: .black,
      textFont: Fonts.regular.uiFont(size: Constants.FontSize.ultraSmall.value),
      color: Colors.grey25.swiftUIColor.uiColor,
      backgroundColor: .clear,
      shadowColor: .clear,
      shadowOffset: .zero,
      shadowOpacity: .zero,
      shadowRadius: 0,
      dismissBehavior: .dismissOnTapEverywhere
    )
  }
}
