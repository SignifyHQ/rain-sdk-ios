import Foundation
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import Services

struct CardDetailItemView: View {
  @StateObject private var viewModel: CardDetailItemViewModel
  @Binding public var isShowCardNumber: Bool
  @Binding public var cardMetaData: CardMetaData?
  @Binding public var isLoading: Bool
  let hasBlurView: Bool
  var isFrntCard: Bool {
    viewModel.cardModel.tokenExperiences?.contains("FRNT") == true
  }
  
  var textColorByCardType: Color {
    isFrntCard ? Colors.grey900.swiftUIColor : Colors.textPrimary.swiftUIColor
  }
  
  @Binding var cardModel: CardModel
  
  init(
    cardModel: Binding<CardModel>,
    cardMetaData: Binding<CardMetaData?>,
    isShowCardNumber: Binding<Bool>,
    isLoading: Binding<Bool>,
    hasBlurView: Bool = false
  ) {
    self._cardModel = cardModel
    _viewModel = .init(wrappedValue: CardDetailItemViewModel(cardModel: cardModel.wrappedValue))
    _cardMetaData = cardMetaData
    _isShowCardNumber = isShowCardNumber
    _isLoading = isLoading
    self.hasBlurView = hasBlurView
  }
  
  var body: some View {
    var backdropImage: Image {
      if isFrntCard {
        return GenImages.Images.frntCardEmpty.swiftUIImage
      }
      
      return cardModel.cardStatus == .closed ? GenImages.Images.imgDisabledCardBackdrop.swiftUIImage : GenImages.Images.emptyCardBackdrop.swiftUIImage
    }
    
    
    ZStack(alignment: .bottom) {
      ZStack(alignment: .topLeading) {
        backdropImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .applyIf(hasBlurView) {
            $0.overlay {
              Colors.grey900.swiftUIColor.opacity(0.4)
            }
          }
        
        HStack {
          Text(viewModel.cardType)
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(textColorByCardType)
          
          Spacer()
          
          lockedView
        }
        .padding([.horizontal, .top], 12)
      }
      
      headerTitleView
    }
    .onChange(of: cardModel.cardStatus) { _, _ in
      viewModel.cardModel = cardModel
    }
    .onChange(of: cardModel.id) { _, _ in
      viewModel.cardModel = cardModel
    }
    .onChange(of: isShowCardNumber) { _, _ in
      if isShowCardNumber {
        viewModel.showCardInformation(cardMetaData: cardMetaData)
      } else {
        viewModel.hideCardInformation()
      }
    }
    .cornerRadius(12)
    .track(name: String(describing: type(of: self)))
    .toast(data: $viewModel.toastData)
  }
}

// MARK: View Components
private extension CardDetailItemView {
  var cardTypeView: some View {
    Text(viewModel.cardModel.cardType.title)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(textColorByCardType)
      .padding(.top, 12)
      .padding(.leading, 12)
  }
  
  @ViewBuilder
  var lockedView: some View {
    if viewModel.cardModel.cardStatus == .disabled {
      HStack(spacing: 6) {
        GenImages.Images.icoLock.swiftUIImage
          .resizable()
          .frame(width: 16, height: 16)
        Text(L10N.Common.CardDetailsList.Detail.Locked.title)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(textColorByCardType)
      }
    }
  }
  
  var physicalTitleView: some View {
    Text(L10N.Common.Card.Physical.name(LFUtilities.cardName))
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(textColorByCardType)
      .padding(.top, -50)
      .padding(.horizontal, 16)
  }
  
  var headerTitleView: some View {
    HStack {
      cardNumberView
        .hidden(viewModel.cardModel.cardStatus == .canceled)
      
      Spacer()
      
      trailingCardView
        .hidden(viewModel.cardModel.cardType == .physical)
    }
    .padding(.bottom, 12)
    .padding(.horizontal, 12)
  }
  
  var trailingCardView: some View {
    HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 6) {
        Text(L10N.Common.CardDetailsList.Detail.Exp.title)
          .foregroundColor(textColorByCardType)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        Text(viewModel.expirationTime)
          .foregroundColor(textColorByCardType)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .hidden(isLoading)
          .frame(width: 52, alignment: .leading)
      }
      
      VStack(alignment: .leading, spacing: 6) {
        Text(L10N.Common.Card.Cvv.title)
          .foregroundColor(textColorByCardType)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        Text(viewModel.cvvNumber)
          .foregroundColor(textColorByCardType)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .hidden(isLoading)
          .frame(width: 52, alignment: .leading)
      }
    }
  }
  
  var cardNumberView: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 4) {
        Text(L10N.Common.CardDetailsList.Detail.CardNumber.title)
          .foregroundColor(textColorByCardType)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        GenImages.Images.icoCopy.swiftUIImage
          .foregroundColor(textColorByCardType)
          .simultaneousGesture(
            TapGesture()
              .onEnded {
                viewModel.copyAction(cardNumber: cardMetaData?.pan)
              }
          )
          .hidden(isLoading || viewModel.cardModel.cardType == .physical || viewModel.cardModel.cardStatus == .closed)
      }
      
      if isLoading {
        DefaultLottieView(loading: .ctaFast)
          .frame(width: 24, height: 24)
      } else {
        Text(viewModel.cardNumber)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(textColorByCardType)
      }
    }
  }
}
