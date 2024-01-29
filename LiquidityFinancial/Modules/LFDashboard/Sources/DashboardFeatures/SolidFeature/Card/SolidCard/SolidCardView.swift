import Foundation
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import Services

struct SolidCardView: View {
  @StateObject
  private var viewModel: SolidCardViewModel
  @Binding
  private var isShowCardNumber: Bool
  
  init(cardModel: CardModel, isShowCardNumber: Binding<Bool>) {
    let cardViewModel = SolidCardViewModel(cardModel: cardModel)
    _viewModel = .init(wrappedValue: cardViewModel)
    _isShowCardNumber = isShowCardNumber
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      emptyCardView
      headerTitleView
      cardInformationView
    }
    .cornerRadius(9)
    .overlay {
      cardCopyMessageView
    }
    .onAppear {
      viewModel.getVGSShowTokenAPI()
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension SolidCardView {
  var emptyCardView: some View {
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
  }
  
  var headerTitleView: some View {
    HStack {
      cardNumberView
      Spacer()
      trailingCardView
    }
    .foregroundColor(Colors.contrast.swiftUIColor.opacity(0.75))
    .padding(.top, -60)
    .padding(.horizontal, 20)
  }
  
  var cardInformationView: some View {
    ZStack(alignment: .leading) {
      VGSShowView(
        vgsShow: viewModel.vgsShow,
        cardModel: $viewModel.cardModel,
        showCardNumber: $isShowCardNumber,
        labelColor: Colors.contrast.swiftUIColor
      )
      .frame(height: 30)
      .opacity(viewModel.isCardAvailable ? 1 : 0)
      LottieView(loading: .contrast)
        .frame(width: 28, height: 15, alignment: .leading)
        .hidden(viewModel.isCardAvailable)
    }
    .padding(EdgeInsets(top: 50, leading: 20, bottom: 15, trailing: 20))
  }
  
  var cardNumberView: some View {
    HStack(spacing: 8) {
      Text(L10N.Common.Card.CardNumber.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      GenImages.CommonImages.icCopy.swiftUIImage
        .foregroundColor(Colors.contrast.swiftUIColor)
        .onTapGesture {
          viewModel.copyAction()
        }
        .hidden(!viewModel.isCardAvailable)
    }
    .frame(width: 180, alignment: .leading)
  }
  
  var trailingCardView: some View {
    HStack(spacing: 32) {
      Text(L10N.Common.Card.Exp.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      Text(L10N.Common.Card.Cvv.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
  }
  
  @ViewBuilder
  var cardCopyMessageView: some View {
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
