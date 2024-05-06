import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import Factory
import PortalSwift

struct RecoverWalletView: View {
  @StateObject var viewModel: RecoverWalletViewModel
  
  init(recoverMethod: BackupMethods) {
    _viewModel = .init(
      wrappedValue: RecoverWalletViewModel(recoverMethod: recoverMethod)
    )
  }
  
  var body: some View {
    VStack(spacing: 24) {
      cardView
      titleView
      Spacer()
      startRecoveryButton
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .iCloudNotFound:
        ICloudBackupNotFoundView()
      case .recoverByPinCode:
        EnterPinCodeView()
      }
    }
    .popup(item: $viewModel.popup) { item in
      switch item {
      case .recoverySuccessfully:
        recoverySuccessfullyPopup
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension RecoverWalletView {
  var cardView: some View {
    VStack(alignment: .leading) {
      GenImages.Images.icContrastLogo.swiftUIImage
        .resizable()
        .frame(48)
        .scaledToFit()
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
      sensitiveCardDataView
    }
    .padding(16)
    .aspectRatio(1.62, contentMode: .fit)
    .background(
      Colors.primary.swiftUIColor.cornerRadius(8)
    )
    .padding(.top, 30)
  }
  
  var sensitiveCardDataView: some View {
    VStack(alignment: .leading, spacing: 16) {
      cardNumberView
      HStack {
        Text(Constants.Default.expirationDateAsteriskPlaceholder.rawValue)
        Spacer()
        Text(String(repeating: Constants.Default.asterisk.rawValue, count: 3))
        Spacer()
        GenImages.CommonImages.logoVisa.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var cardNumberView: some View {
    HStack {
      ForEach(0..<3, id: \.self) { _ in
        Text(String(repeating: Constants.Default.asterisk.rawValue, count: 4))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
      }
      if viewModel.panLast4.isEmpty {
        Text(String(repeating: Constants.Default.asterisk.rawValue, count: 4))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      } else {
        Text(viewModel.panLast4)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
  
  var titleView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.RecoverWallet.title(viewModel.recoverMethod.rawValue).uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(viewModel.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var startRecoveryButton: some View {
    FullSizeButton(
      title: L10N.Common.RecoverWallet.StartRecovery.buttonTitle,
      isDisable: false,
      isLoading: $viewModel.isLoading
    ) {
      viewModel.startRecoveryButtonTapped()
    }
  }
  
  var recoverySuccessfullyPopup: some View {
    LiquidityAlert(
      title:  L10N.Common.RecoveryComplete.title.uppercased(),
      message: L10N.Common.RecoveryComplete.message,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.recoverySuccessfullyPrimaryButtonTapped()
      }
    )
  }
}
