import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import VGSShowSDK

struct VGSCardView: View {
  @StateObject
  private var viewModel: VGSCardViewModel
  @Binding
  private var card: CardModel
  
  init(card: Binding<CardModel>) {
    let cardViewModel = VGSCardViewModel(card: card.wrappedValue)
    _viewModel = .init(wrappedValue: cardViewModel)
    _card = card
  }
  
  var body: some View {
    content
      .onChange(of: card.cardStatus) { newValue in
        if newValue == .closed {
          viewModel.hideSensitiveData()
        }
      }
      .onDisappear {
        viewModel.hideSensitiveData()
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
  }
}

// MARK: - View Components
private extension VGSCardView {
  var content: some View {
    VStack(alignment: .leading) {
      topCardView
      Spacer()
      sensitiveCardDataView
      if !viewModel.isCardAvailable {
        // TODO: We will custom this animation to support multi-color
        LottieView(loading: .contrast)
          .frame(width: 28, height: 15, alignment: .leading)
      }
    }
    .padding(16)
    .frame(height: 192)
    .background(
      card.backgroundColor.cornerRadius(8)
    )
    .overlay {
      copyMessageView
    }
  }
  
  var topCardView: some View {
    HStack(alignment: .top) {
      cardBrandView
      Spacer()
      topTrailingCardView
    }
  }
  
  @ViewBuilder
  var topTrailingCardView: some View {
    if card.cardStatus == .closed {
      Text(L10N.Common.Card.Closed.title)
        .foregroundColor(card.textColor)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(
          Colors.whiteText.swiftUIColor
            .opacity(0.5)
            .cornerRadius(4)
        )
    } else if card.cardStatus == .disabled || card.cardStatus == .unactivated {
      GenImages.Images.icCirclePause.swiftUIImage
        .resizable()
        .frame(32)
    }
  }
  
  @ViewBuilder
  var cardBrandView: some View {
    if card.isDisplayLogo {
      // TODO: - We will handle merchantLocked logo later
      GenImages.Images.icContrastLogo.swiftUIImage
        .resizable()
        .frame(40)
        .scaledToFit()
        .foregroundColor(card.textColor)
    } else {
      Text(card.cardName)
        .foregroundColor(card.textColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .lineLimit(1)
    }
  }
  
  var sensitiveCardDataView: some View {
    VGSShowView(
      isShowCardNumber: $viewModel.isShowCardNumber,
      isShowExpDateAndCVVCode: $viewModel.isShowExpDateAndCVVCode,
      vgsShow: viewModel.vgsShow,
      cardModel: card,
      labelColor: card.textColor,
      copyAction: {
        viewModel.copyToClipboard(type: .expDateAndCVV, card: card)
      }
    )
    .frame(height: 76)
    .overlay(alignment: .bottomTrailing) {
      GenImages.CommonImages.logoVisa.swiftUIImage
        .foregroundColor(card.textColor)
    }
    .overlay(alignment: .top) {
      VStack(alignment: .leading, spacing: 8) {
        secureCardNumber
        secureExpDateAndCVVCode
      }
      .padding(.top, 18)
    }
    .opacity(viewModel.isCardAvailable ? 1 : 0)
    .disabled(card.cardStatus == .closed)
  }
  
  var secureCardNumber: some View {
    HStack {
      ForEach(0..<3, id: \.self) { _ in
        Text(String(repeating: Constants.Default.asterisk.rawValue, count: 4))
          .contentShape(Rectangle())
          .onTapGesture {
            viewModel.showCardNumber()
          }
        Spacer()
      }
      .opacity(viewModel.isShowCardNumber ? 0 : 1)
      Text(card.last4)
        .opacity(viewModel.isShowCardNumber ? 0 : 1)
    }
    .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
    .foregroundColor(card.textColor)
    .frame(height: 27)
    .background(
      Colors.whiteText.swiftUIColor
        .opacity(viewModel.isShowCardNumber ? 0.25 : 0)
        .cornerRadius(32)
    )
    .padding(.horizontal, viewModel.isShowCardNumber ? -8 : 0)
    .offset(y: -3)
    .onTapGesture {
      guard viewModel.isShowCardNumber else { return }
      viewModel.copyToClipboard(type: .cardNumber, card: card)
    }
  }
  
  var secureExpDateAndCVVCode: some View {
    HStack(alignment: .top, spacing: 90) {
      Text(Constants.Default.expirationDateAsteriskPlaceholder.rawValue)
        .onTapGesture {
          viewModel.showExpDateAndCVVCode()
        }
      Text(String(repeating: Constants.Default.asterisk.rawValue, count: 3))
        .onTapGesture {
          viewModel.showExpDateAndCVVCode()
        }
    }
    .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
    .foregroundColor(card.textColor.opacity(0.75))
    .opacity(viewModel.isShowExpDateAndCVVCode ? 0 : 1)
  }
  
  @ViewBuilder
  var copyMessageView: some View {
    if let message = viewModel.copyMessage {
      Text(message)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(card.textColor)
        .frame(maxWidth: .infinity)
        .frame(height: 20, alignment: .center)
        .background(Colors.whiteText.swiftUIColor.opacity(0.25))
    }
  }
}
