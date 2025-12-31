import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import GeneralFeature

struct WithdrawalAmountEntryView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var viewModel: WithdrawalAmountEntryViewModel

  @State private var isShowAnnotationView: Bool = false
  
  private let completeAction: (() -> Void)?
  
  init(
    assetModel: AssetModel,
    address: String,
    nickname: String,
    completeAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: WithdrawalAmountEntryViewModel(
        assetModel: assetModel,
        address: address,
        nickname: nickname
      )
    )
    
    self.completeAction = completeAction
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      headerView
      withdrawalAmountView
      Spacer()
      keyboardView
      Spacer()
      footerView
    }
    .appNavBar(
      navigationTitle: L10N.Common.WithdrawalAmount.Screen.title
    )
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .frame(maxWidth: .infinity)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: viewModel.amountInput) { _ in
      viewModel.validateAmountInput()
    }
    .toast(data: $viewModel.toastData)
    .popup(item: $viewModel.blockPopup, dismissMethods: [.tapInside]) { popup in
      switch popup {
      case .retryWithdrawalAfter(let duration):
        retryWithdrawalPopup(duration: duration)
      }
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .confirmTransfer(let viewModel):
        WithdrawalConfirmationView(
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
extension WithdrawalAmountEntryView {
  var headerView: some View {
    Text(L10N.Common.WalletAddressInput.Header.title)
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
      .multilineTextAlignment(.leading)
  }
  
  var withdrawalAmountView: some View {
    VStack(alignment: .leading, spacing: 24) {
      amountInputView
      amountPresetView
    }
    .overlay {
      cryptoDropdownView
    }
  }
  
  var amountInputView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(L10N.Common.WithdrawalAmount.Input.title)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      
      VStack(alignment: .leading, spacing: 8) {
        inputView
        Divider()
          .frame(height: 1)
          .background(Colors.linesDividers.swiftUIColor)
          .frame(maxWidth: .infinity)
        availableAmountView
      }
    }
  }
  
  @ViewBuilder
  var availableAmountView: some View {
    if let error = viewModel.inlineError {
      errorView(error: error)
    } else if let availableAmount = viewModel.availableAmount {
      Text(availableAmount)
        .foregroundColor(Colors.textTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
  }
  
  var inputView: some View {
    HStack(
      alignment: .center,
      spacing: 8
    ) {
      if viewModel.assetModelList.isNotEmpty {
        Button {
          viewModel.isShowingTokenDropdown.toggle()
        } label: {
          HStack(spacing: 4) {
            HStack(spacing: 2) {
              viewModel.assetModel.type?.icon?
                .resizable()
                .frame(width: 16, height: 16)
              
              Text(viewModel.assetModel.type?.symbol ?? "N/A")
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
                .foregroundColor(Colors.textPrimary.swiftUIColor)
            }
            
            GenImages.CommonImages.icArrowDown.swiftUIImage
              .tint(Colors.iconPrimary.swiftUIColor)
              .rotationEffect(
                .degrees(viewModel.isShowingTokenDropdown ? 180 : 0)
              )
          }
          .padding(8)
          .background(Colors.grey400.swiftUIColor.cornerRadius(4))
        }
      } else {
        viewModel.assetModel.type?.icon
      }
      
      Text(viewModel.amountInput)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.otp.value))
        .lineLimit(1)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
      Spacer()
      if viewModel.inlineError.isNotNil {
        GenImages.Images.icoError.swiftUIImage
          .resizable()
          .frame(width: 24, height: 24)
      }
    }
    .shakeAnimation(with: viewModel.numberOfShakes)
  }
  
  func errorView(error: String) -> some View {
    Text(error)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundColor(Colors.error.swiftUIColor)
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
      .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
  }
  
  var amountPresetView: some View {
    AmountPresetView(
      selectedValue: $viewModel.selectedValue,
      preFilledValues: viewModel.gridValues,
      action: viewModel.onSelectedGridItem
    )
  }
  
  var keyboardView: some View {
    NumberKeyboardView(
      value: $viewModel.amountInput,
      action: viewModel.resetSelectedValue,
      maxFractionDigits: viewModel.maxFractionDigits
    )
  }
  
  var footerView: some View {
    continueButton
      .padding(.bottom, 16)
  }
  
  var continueButton: some View {
    let title = viewModel.shouldRetryWithdrawal ? L10N.Common.Common.Retry.Button.title : L10N.Common.Common.Continue.Button.title
    return FullWidthButton(
      type: .primary,
      title: title,
      isDisabled: !viewModel.isActionAllowed,
      isLoading: $viewModel.isPerformingAction
    ) {
      viewModel.onContinueButtonTap()
    }
  }
  
  var cryptoDropdownView: some View {
    DropdownView.simple(
      items: viewModel.dropdownAssetModelList,
      selectedItem: .constant(nil),
      showDropdown: $viewModel.isShowingTokenDropdown,
      onItemSelected: { asset in
        viewModel.assetModel = asset
      },
      itemDisplayName: { asset in
        asset.type?.symbol ?? "N/A"
      },
      itemDisplayIcon: { asset in
        asset.type?.icon
      }
    )
    .padding(.top, 8)
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
