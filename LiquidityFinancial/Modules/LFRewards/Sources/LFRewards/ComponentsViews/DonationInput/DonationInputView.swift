import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct DonationInputView: View {
  @StateObject private var viewModel: DonationInputViewModel
  @State private var showAnnotationView: Bool = false
  @State private var screenSize: CGSize = .zero
  
  init(type: DonationInputViewModel.Kind) {
    _viewModel = StateObject(wrappedValue: .init(type: type))
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
    .background(ModuleColors.background.swiftUIColor)
    .onAppear(perform: viewModel.onAppear)
    .onChange(of: viewModel.amountInput) { _ in
      viewModel.validateAmountInput()
    }
    .onTapGesture {
      showAnnotationView = false
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationBarTitleDisplayMode(.inline)
//    .navigationLink(item: $viewModel.navigation) { navigation in
//      switch navigation {
//      case let .detail(viewModel):
//        BuySellDetailView(viewModel: viewModel)
//      }
//    }
  }
  
  private var header: some View {
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
        .opacity(showAnnotationView ? 1 : 0)
    }
  }
  
  @ViewBuilder private var titleView: some View {
    if viewModel.isFetchingData {
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
    } else {
      HStack {
        Spacer()
        VStack(spacing: 10) {
          Text(viewModel.title)
            .font(Fonts.regular.swiftUIFont(size: 18))
            .foregroundColor(ModuleColors.label.swiftUIColor)
          HStack(spacing: 4) {
            if let subtitle = viewModel.subtitle {
              Text(subtitle)
                .font(Fonts.regular.swiftUIFont(size: 12))
                .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.5))
            }

            GenImages.CommonImages.info.swiftUIImage
              .foregroundColor(ModuleColors.label.swiftUIColor)
              .frame(width: 16, height: 16)
              .onTapGesture {
                showAnnotationView.toggle()
              }
          }
        }
        Spacer()
      }
    }
  }
  
  private var amountInput: some View {
    VStack(spacing: 12) {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        if viewModel.isUSDCurrency {
          ModuleImages.icUsdSymbol.swiftUIImage
            .foregroundColor(ModuleColors.label.swiftUIColor)
        }
        Text(viewModel.amountInput)
          .font(Fonts.bold.swiftUIFont(size: 50))
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
      .shakeAnimation(with: viewModel.numberOfShakes)
      error
    }
  }
  
  private var error: some View {
    Text(viewModel.inlineError ?? String.empty)
      .font(Fonts.regular.swiftUIFont(size: 14))
      .foregroundColor(ModuleColors.red.swiftUIColor)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
  }
  
  private var preFilledGrid: some View {
    PreFilledGridView(
      selectedValue: $viewModel.selectedValue,
      preFilledValues: viewModel.gridValues,
      action: viewModel.onSelectedGridItem
    )
  }
  
  private var keyboard: some View {
    KeyboardCustomView(
      value: $viewModel.amountInput,
      action: viewModel.resetSelectedValue,
      maxFractionDigits: viewModel.maxFractionDigits,
      disable: false
    )
    .padding(.vertical, 32)
  }
  
  private var footer: some View {
    VStack(spacing: 16) {
      continueButton
    }
  }
  
  private var continueButton: some View {
    FullSizeButton(title: L10N.Common.Button.Continue.title, isDisable: viewModel.isActionAllowed, isLoading: $viewModel.isPerformingAction) {
      viewModel.continueButtonTapped()
    }
  }
}
