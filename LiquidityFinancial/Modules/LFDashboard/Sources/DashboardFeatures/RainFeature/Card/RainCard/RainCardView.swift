import Foundation
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import Services

struct RainCardView: View {
  @StateObject private var viewModel: RainCardViewModel
  @Binding public var isShowCardNumber: Bool
  @Binding public var cardMetaData: CardMetaData?
  @Binding public var isLoading: Bool

  init(
    cardModel: CardModel,
    cardMetaData: Binding<CardMetaData?>,
    isShowCardNumber: Binding<Bool>,
    isLoading: Binding<Bool>
  ) {
    _viewModel = .init(wrappedValue: RainCardViewModel(cardModel: cardModel))
    _cardMetaData = cardMetaData
    _isShowCardNumber = isShowCardNumber
    _isLoading = isLoading
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .topLeading) {
        GenImages.Images.emptyCard.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
        Text(viewModel.cardModel.cardType.title)
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.contrast.swiftUIColor)
          .padding(.top, 15)
          .padding(.leading, 10)
      }
      headerTitleView
      physicalTitleView
        .opacity(viewModel.cardModel.cardType != .physical ? 0 : 1)
    }
    .onChange(of: isShowCardNumber) { _ in
      if isShowCardNumber {
        viewModel.showCardInformation(cardMetaData: cardMetaData)
      } else {
        viewModel.hideCardInformation()
      }
    }
    .cornerRadius(9)
    .overlay {
      cardCopyMessageView
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension RainCardView {
  var physicalTitleView: some View {
    HStack {
      Text(L10N.Common.Card.Physical.name(LFUtilities.cardName))
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.contrast.swiftUIColor)
    }
    .foregroundColor(Colors.contrast.swiftUIColor.opacity(0.75))
    .padding(.top, -50)
    .padding(.horizontal, 16)
  }
  
  var headerTitleView: some View {
    HStack {
      cardNumberView
      Spacer()
      trailingCardView
        .hidden(viewModel.cardModel.cardType == .physical)
    }
    .foregroundColor(Colors.contrast.swiftUIColor.opacity(0.75))
    .padding(.top, -50)
    .padding(.leading, 16)
  }
  
  var trailingCardView: some View {
    HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 6) {
        Text(L10N.Common.Card.Exp.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        Text(viewModel.expirationTime)
          .foregroundColor(Colors.contrast.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .hidden(isLoading)
          .frame(width: 50, alignment: .leading)
      }
      
      VStack(alignment: .leading, spacing: 6) {
        Text(L10N.Common.Card.Cvv.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        Text(viewModel.cvvNumber)
          .foregroundColor(Colors.contrast.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .hidden(isLoading)
          .frame(width: 45, alignment: .leading)
      }
    }
  }
  
  var cardNumberView: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 8) {
        Text(L10N.Common.Card.CardNumber.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .hidden(viewModel.cardModel.cardType == .physical)
        GenImages.CommonImages.icCopy.swiftUIImage
          .foregroundColor(Colors.contrast.swiftUIColor)
          .onTapGesture {
            viewModel.copyAction(cardNumber: cardMetaData?.pan)
          }
          .hidden(isLoading || viewModel.cardModel.cardType == .physical)
      }
      
      if isLoading {
        LottieView(loading: .contrast)
          .frame(width: 30, height: 20)
      } else {
        Text(viewModel.cardNumber)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.contrast.swiftUIColor)
      }
    }
  }
  
  @ViewBuilder var cardCopyMessageView: some View {
    if viewModel.isShowCardCopyMessage {
      Text(L10N.Common.Card.CardNumberCopied.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(maxWidth: .infinity)
        .frame(height: 20, alignment: .center)
        .background(Colors.secondaryBackground.swiftUIColor.opacity(0.9))
    }
  }
}
