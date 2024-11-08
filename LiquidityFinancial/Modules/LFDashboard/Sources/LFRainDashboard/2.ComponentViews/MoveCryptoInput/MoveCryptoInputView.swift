import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import GeneralFeature

struct MoveCryptoInputView: View {
  @StateObject private var viewModel: MoveCryptoInputViewModel
  @Environment(\.dismiss) var dismiss

  @State private var isShowAnnotationView: Bool = false
  @State private var screenSize: CGSize = .zero
  @State private var dropdownFrame: CGRect = .zero
  
  private let completeAction: (() -> Void)?
  
  init(
    type: MoveCryptoInputViewModel.Kind,
    assetModel: AssetModel,
    completeAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: MoveCryptoInputViewModel(type: type, assetModel: assetModel)
    )
    
    self.completeAction = completeAction
  }
  
  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        header
        keyboard
        footer
      }
      
      if viewModel.isShowingTokenSelection {
        dropdownView()
          .frame(
            width: dropdownFrame.width,
            height: dropdownFrame.height * 2
          )
          .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
          .position(
            x: dropdownFrame.midX - 30,
            y: dropdownFrame.maxY - dropdownFrame.height + 12
          )
      }
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
    .popup(item: $viewModel.blockPopup, dismissMethods: [.tapInside]) { popup in
      switch popup {
      case .retryWithdrawalAfter(let duration):
        retryWithdrawalPopup(duration: duration)
      }
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .confirmTransfer(let viewModel):
        ConfirmTransferMoneyView(
          viewModel: viewModel,
          completeAction: completeAction
        )
      }
    }
    .track(name: String(describing: type(of: self)))
    .disabled(viewModel.isLoading)
  }
}

// MARK: - View Components
private extension MoveCryptoInputView {
  var header: some View {
    ZStack(
      alignment: viewModel.isFetchingData ? .center : .topLeading
    ) {
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
      HStack(
        alignment: .center,
        spacing: 4
      ) {
        Text(viewModel.amountInput)
          .font(Fonts.bold.swiftUIFont(size: 50))
          .foregroundColor(Colors.label.swiftUIColor)
        
        if viewModel.shouldShowTokenSelection && viewModel.assetModelList.isNotEmpty {
          Button {
            viewModel.isShowingTokenSelection.toggle()
          } label: {
            HStack {
              viewModel.assetModel.type?.image
              
              Text(viewModel.assetModel.type?.title ?? "-/-")
                .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
                .foregroundColor(Colors.label.swiftUIColor)
                .padding(.horizontal, 12)
              
              GenImages.CommonImages.icArrowDown.swiftUIImage
                .tint(Colors.label.swiftUIColor)
                .rotationEffect(
                  .degrees(viewModel.isShowingTokenSelection ? 180 : 0)
                )
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
          }
          .readGeometry { geometry in
            dropdownFrame = geometry.frame(in: .global)
          }
        } else {
          viewModel.assetModel.type?.image
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
        //cryptoDisclosure
        estimatedFeeDescription
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: viewModel.shouldRetryWithdrawal ? L10N.Common.Button.Retry.title : L10N.Common.Button.Continue.title,
      isDisable: !viewModel.isActionAllowed,
      isLoading: $viewModel.isPerformingAction
    ) {
      viewModel.continueButtonTapped()
    }
  }
  
//  @ViewBuilder var cryptoDisclosure: some View {
//    if viewModel.showCryptoDisclosure {
//      Text(L10N.Common.Zerohash.Disclosure.description)
//        .font(Fonts.regular.swiftUIFont(size: 10))
//        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
//        .fixedSize(horizontal: false, vertical: true)
//    }
//  }
  
  @ViewBuilder var estimatedFeeDescription: some View {
    if viewModel.showEstimatedFeeDescription {
      Text(L10N.Common.MoveCryptoInput.Send.estimatedFee)
        .multilineTextAlignment(.center)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  func dropdownView(
  ) -> some View {
    List(
      viewModel.assetModelList,
      id: \.id
    ) { item in
      HStack {
        item.type?.image
          .padding(.leading, -5)
        
        Text(item.type?.title ?? "-/-")
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.leading, 12)
      }
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
      .listRowInsets(.none)
      .onTapGesture {
        viewModel.assetModel = item
        viewModel.isShowingTokenSelection = false
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .onAppear {
      UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    }
    .floatingShadow()
  }
  
  func retryWithdrawalPopup(
    duration: Int
  ) -> some View {
    LiquidityLoadingAlert(
      title: L10N.Common.MoveCryptoInput.WithdrawalSignatureProcessing.title,
      message: L10N.Common.MoveCryptoInput.WithdrawalSignatureProcessing.message(
        duration
      ),
      duration: duration
    ) {
      viewModel.handleAfterWaitingRetryTime()
    }
  }
}
