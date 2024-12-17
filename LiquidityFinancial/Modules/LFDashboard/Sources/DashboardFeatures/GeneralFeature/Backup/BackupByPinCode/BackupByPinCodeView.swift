import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountData
import Services

public struct BackupByPinCodeView: View {
  @StateObject private var viewModel: BackupByPinCodeViewModel
  
  public init(purpose: BackupByPinCodeViewModel.Purpose) {
    _viewModel = .init(
      wrappedValue: BackupByPinCodeViewModel(purpose: purpose)
    )
  }
  
  public var body: some View {
    content
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .confirmBackupPin:
          BackupByPinCodeView(purpose: .confirm(viewModel.pinCode))
        }
      }
      .popup(item: $viewModel.popup, dismissMethods: .tapInside) { item in
        switch item {
        case .pinCreated:
          pinCreatedPopup
        case .pinSecure:
          pinSecurePopup
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension BackupByPinCodeView {
  var content: some View {
    VStack(alignment: .leading, spacing: 24) {
      headerTitle
      pinCodeView
      Spacer()
      bottomButtonView
    }
    .padding(30)
    .background(Colors.background.swiftUIColor)
  }
  
  var pinCodeView: some View {
    VStack(spacing: 24) {
      PinCodeView(
        code: $viewModel.pinCode,
        isDisabled: $viewModel.isLoading,
        codeLength: viewModel.pinCodeLength,
        isSecureInput: true
      )
      if let errorMessage = viewModel.inlineMessage {
        Text(errorMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.error.swiftUIColor)
      }
    }
    .padding(.top, 80)
    .padding(.horizontal, 24)
  }
  
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(viewModel.purpose.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(viewModel.purpose.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var bottomButtonView: some View {
    FullSizeButton(
      title: viewModel.purpose.buttonTitle,
      isDisable: viewModel.isButtonDisable,
      isLoading: $viewModel.isLoading
    ) {
      viewModel.primaryButtonTapped()
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
  
  var pinCreatedPopup: some View {
    LiquidityAlert(
      title: L10N.Common.BackupByPinCode.PinCreatedPopup.title.uppercased(),
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.primaryPinCreatedButtonTapped()
      }
    )
  }
  
  var pinSecurePopup: some View {
    LiquidityAlert(
      title: L10N.Common.BackupByPinCode.PinSecurePopup.title.uppercased(),
      message: L10N.Common.BackupByPinCode.PinSecurePopup.message,
      primary: .init(text: L10N.Common.BackupByPinCode.PinSecurePopup.primaryButton) {
        viewModel.pinSecureButtonTapped()
      },
      secondary: .init(text: L10N.Common.Button.NotNow.title) {
        viewModel.pinSecureButtonTapped()
      }
    )
  }
}
