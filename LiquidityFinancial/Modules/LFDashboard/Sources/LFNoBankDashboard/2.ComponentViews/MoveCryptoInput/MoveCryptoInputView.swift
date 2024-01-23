import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import GeneralFeature

struct MoveCryptoInputView: View {
  @StateObject private var viewModel: MoveCryptoInputViewModel
  @State private var isShowAnnotationView: Bool = false
  @State private var screenSize: CGSize = .zero
  private let completeAction: (() -> Void)?
  
  init(type: MoveCryptoInputViewModel.Kind, assetModel: AssetModel, completeAction: (() -> Void)? = nil) {
    _viewModel = .init(
      wrappedValue: MoveCryptoInputViewModel(type: type, assetModel: assetModel)
    )
    self.completeAction = completeAction
  }
  
  var body: some View {
    VStack(spacing: 0) {
      header
      keyboard
      footer
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
    .frame(maxWidth: .infinity)
    .readGeometry { geo in
      screenSize = geo.size
    }
    .background(Colors.background.swiftUIColor)
    .onChange(of: viewModel.amountInput) { _ in
      viewModel.validateAmountInput()
    }
    .onTapGesture {
      isShowAnnotationView = false
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .detail:
        EmptyView()
      case .confirmSend(let lockedFeeResponse):
        ConfirmSendCryptoView(
          assetModel: viewModel.assetModel,
          amount: viewModel.amount,
          address: viewModel.address,
          nickname: viewModel.nickname,
          feeLockedResponse: lockedFeeResponse,
          completeAction: completeAction
        )
      }
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension MoveCryptoInputView {
  var header: some View {
    ZStack(alignment: viewModel.isFetchingData ? .center : .topLeading) {
      VStack(spacing: 0) {
        titleView
        Spacer()
        amountInput
        Spacer()
        preFilledGrid
      }
      AnnotationView(
        description: viewModel.annotationString,
        corners: [.topLeft, .bottomLeft, .bottomRight]
      )
        .frame(width: screenSize.width * 0.64)
        .offset(x: -10, y: 56)
        .opacity(isShowAnnotationView ? 1 : 0)
    }
  }
  
  @ViewBuilder var titleView: some View {
    if viewModel.isFetchingData {
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
    } else {
      HStack {
        Spacer()
        VStack(spacing: 10) {
          Text(viewModel.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .foregroundColor(Colors.label.swiftUIColor)
          HStack(spacing: 4) {
            if let subTitle = viewModel.subtitle {
              Text(subTitle)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
            }
            GenImages.CommonImages.info.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
              .frame(16)
              .onTapGesture {
                isShowAnnotationView.toggle()
              }
          }
        }
        Spacer()
      }
    }
  }
  
  var amountInput: some View {
    VStack(spacing: 12) {
      HStack(alignment: .lastTextBaseline, spacing: 4) {
        if viewModel.isUSDCurrency {
          GenImages.CommonImages.usdSymbol.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
        Text(viewModel.amountInput)
          .font(Fonts.bold.swiftUIFont(size: 50))
          .foregroundColor(Colors.label.swiftUIColor)
        if viewModel.isCryptoCurrency, let image = viewModel.cryptoIconImage {
          image
        }
      }
      .shakeAnimation(with: viewModel.numberOfShakes)
      error
    }
  }
  
  var error: some View {
    Text(viewModel.inlineError ?? String.empty)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.error.swiftUIColor)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
  }
  
  var preFilledGrid: some View {
    PreFilledGridView(
      selectedValue: $viewModel.selectedValue,
      preFilledValues: viewModel.gridValues,
      action: viewModel.onSelectedGridItem
    )
  }
  
  var keyboard: some View {
    KeyboardCustomView(
      value: $viewModel.amountInput,
      action: viewModel.resetSelectedValue,
      maxFractionDigits: viewModel.maxFractionDigits,
      disable: viewModel.type == .sellCrypto && viewModel.isFetchingData
    )
    .padding(.vertical, 32)
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      continueButton
      VStack(spacing: 12) {
        cryptoDisclosure
        estimatedFeeDescription
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: !viewModel.isActionAllowed,
      isLoading: $viewModel.isPerformingAction
    ) {
      viewModel.continueButtonTapped()
    }
  }
  
  @ViewBuilder var cryptoDisclosure: some View {
    if viewModel.showCryptoDisclosure {
      Text(L10N.Common.Zerohash.Disclosure.description)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  @ViewBuilder var estimatedFeeDescription: some View {
    if viewModel.showEstimatedFeeDescription {
      Text(L10N.Common.MoveCryptoInput.Send.estimatedFee)
        .multilineTextAlignment(.center)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}
