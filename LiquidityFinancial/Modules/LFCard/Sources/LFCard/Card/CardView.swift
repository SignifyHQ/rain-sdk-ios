import Foundation
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import VGSShowSDK

struct CardView: View {
  @StateObject private var viewModel: CardViewModel
  @Binding private var isShowCardNumber: Bool

  init(card: CardModel, isShowCardNumber: Binding<Bool>) {
    _isShowCardNumber = isShowCardNumber
    _viewModel = .init(
      wrappedValue: CardViewModel(cardModel: card)
    )
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ZStack(alignment: .topLeading) {
        GenImages.Images.emptyCard.swiftUIImage
          .resizable()
        Text(viewModel.cardModel.cardType.title)
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.top, 15)
          .padding(.leading, 10)
      }
      headerTitleView
      ZStack(alignment: .leading) {
        VGSShowView(
          vgsShow: viewModel.vgsShow,
          cardModel: $viewModel.cardModel,
          showCardNumber: $isShowCardNumber
        )
        .frame(height: 30)
        .opacity(viewModel.isCardAvailable ? 1 : 0)
        loadingView
      }
      .padding(.top, 50)
      .padding(.bottom, 15)
      .padding(.horizontal, 20)
    }
    .cornerRadius(9)
    .overlay {
      cardCopyMessageView
    }
  }
}

// MARK: View Components
private extension CardView {
  var loadingView: some View {
    HStack(spacing: 30) {
      LottieView(loading: .contrast)
        .frame(width: 28, height: 15, alignment: .leading)
      Spacer()
      LottieView(loading: .contrast)
        .frame(width: 28, height: 15, alignment: .leading)
      LottieView(loading: .contrast)
        .frame(width: 28, height: 15, alignment: .leading)
    }
    .hidden(viewModel.isCardAvailable)
  }
  
  var headerTitleView: some View {
    HStack {
      HStack(spacing: 8) {
        Text(LFLocalizable.Card.CardNumber.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        GenImages.CommonImages.icCopy.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
          .onTapGesture {
            viewModel.copyAction()
          }
          .hidden(!viewModel.isCardAvailable)
      }
      Spacer()
      HStack(spacing: 36) {
        Text(LFLocalizable.Card.Exp.title)
        Text(LFLocalizable.Card.Cvv.title)
      }
      .padding(.trailing, 10)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
    .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    .padding(.top, -58)
    .padding(.horizontal, 16)
  }
  
  @ViewBuilder var cardCopyMessageView: some View {
    if viewModel.isShowCardCopyMessage {
      Text(LFLocalizable.Card.CopyToClipboard.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(maxWidth: .infinity)
        .frame(height: 20, alignment: .center)
        .background(Colors.secondaryBackground.swiftUIColor.opacity(0.9))
    }
  }
}
