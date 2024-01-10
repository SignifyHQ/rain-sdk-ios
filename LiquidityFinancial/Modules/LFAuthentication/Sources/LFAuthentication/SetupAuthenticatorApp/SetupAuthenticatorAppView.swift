import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct SetupAuthenticatorAppView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = SetupAuthenticatorAppViewModel()
  @State private var isSavedRecoveryCode = false
  
  private let continueButtonID = "continueButtonID"
  
  var body: some View {
    ZStack {
      if viewModel.isInit {
        loadingView
      } else {
        content
      }
    }
    .padding(.horizontal, 30)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(item: $viewModel.blockPopup, dismissMethods: []) { item in
      switch item {
      case .recoveryCode:
        recoveryCodePopup
      }
    }
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

private extension SetupAuthenticatorAppView {
  var content: some View {
    AdaptiveKeyboardScrollView(destinationViewID: continueButtonID) {
      VStack(alignment: .leading, spacing: 32) {
        headerView
        instructionView
        FullSizeButton(
          title: LFLocalizable.Button.Verify.title,
          isDisable: viewModel.isDisableVerifyButton,
          isLoading: $viewModel.isVerifyingTOTP
        ) {
          hideKeyboard()
          viewModel.enableMFAAuthentication()
        }
        .padding(.bottom, 16)
      }
      .id(continueButtonID)
    }
  }
  
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(max: .infinity)
  }
  
  var headerView: some View {
    VStack(spacing: 24) {
      Text(LFLocalizable.Authentication.SetupMfa.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      Text(LFLocalizable.Authentication.SetupMfa.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var instructionView: some View {
    VStack(alignment: .leading, spacing: 20) {
      setupStep(
        title: LFLocalizable.Authentication.SetupMfa.downloadAppTitle,
        description: LFLocalizable.Authentication.SetupMfa.downloadAppDescription
      )
      setupStep(
        title: LFLocalizable.Authentication.SetupMfa.scanQrCodeTitle,
        description: LFLocalizable.Authentication.SetupMfa.scanQrCodeDescription
      )
      qrImageView
      setupStep(
        title: LFLocalizable.Authentication.SetupMfa.verify2faCodeTitle,
        description: LFLocalizable.Authentication.SetupMfa.verify2faCodeDescription
      )
      enterVerificationCodeView
    }
  }
  
  func setupStep(title: String, description: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        Circle()
          .fill(Colors.primary.swiftUIColor)
          .frame(5)
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
      Text(description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
    }
    .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
  }
  
  var enterVerificationCodeView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.Authentication.SetupMfa.enterCodeTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      TextFieldWrapper {
        TextField("", text: $viewModel.verificationCode)
          .primaryFieldStyle()
          .keyboardType(.numberPad)
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: viewModel.verificationCode.isEmpty,
              placeholder: LFLocalizable.Authentication.SetupMfa.enterCodePlaceHolder
            )
          )
          .autocorrectionDisabled()
          .limitInputLength(
            value: $viewModel.verificationCode,
            length: Constants.MaxCharacterLimit.mfaCode.value
          )
      }
      .disabled(viewModel.isVerifyingTOTP)
    }
  }
  
  var qrImageView: some View {
    VStack {
      Image(uiImage: viewModel.qrCode)
        .resizable()
        .interpolation(.none)
        .scaledToFit()
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .top], 32)
        .padding(.bottom, 16)
      GenImages.CommonImages.dash.swiftUIImage
      secretKeyView
    }
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10.0)
  }
  
  var secretKeyView: some View {
    HStack(alignment: .top, spacing: 12) {
      Text(viewModel.secretKey)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
      GenImages.CommonImages.icCopy.swiftUIImage
        .resizable()
        .frame(24)
        .foregroundColor(Colors.primary.swiftUIColor)
        .onTapGesture {
          viewModel.copyText(text: viewModel.secretKey)
        }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 12)
    .padding([.horizontal, .bottom], 16)
  }
}

// MARK: - Recovery Popup
private extension SetupAuthenticatorAppView {
  var recoveryCodePopup: some View {
    PopupAlert(padding: 16) {
      VStack(spacing: 32) {
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .frame(100)
        VStack(alignment: .leading, spacing: 24) {
          recoveryCodeTitleView
          recoveryCodeView
        }
        FullSizeButton(title: LFLocalizable.Button.Continue.title, isDisable: !isSavedRecoveryCode) {
          viewModel.hidePopup()
          dismiss()
        }
        .padding(.bottom, 8)
      }
    }
  }

  var recoveryCodeTitleView: some View {
    VStack(spacing: 16) {
      Text(LFLocalizable.Authentication.SetupMfa.recoveryCodePopupTitle.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      Text(LFLocalizable.Authentication.SetupMfa.recoveryCodePopupMessage)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .lineSpacing(1.33)
    }
  }
  
  var recoveryCodeView: some View {
    VStack(spacing: 8) {
      RoundedRectangle(cornerRadius: 10)
        .stroke(Colors.label.swiftUIColor.opacity(0.25), lineWidth: 1)
        .frame(height: 40)
        .overlay {
          Text(viewModel.recoveryCode)
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      FullSizeButton(
        title: LFLocalizable.Authentication.SetupMfa.recoveryCodeCopyCodeButton,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.copyText(text: viewModel.recoveryCode)
      }
      recoveryCheckBox
    }
  }
  
  var recoveryCheckBox: some View {
    HStack(spacing: 10) {
      RoundedRectangle(cornerRadius: 2)
        .stroke(Colors.label.swiftUIColor, lineWidth: 1.5)
        .frame(18)
        .overlay {
          ZStack {
            if isSavedRecoveryCode {
              GenImages.CommonImages.icCheckmark.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
            }
          }
        }
        .onTapGesture {
          isSavedRecoveryCode.toggle()
        }
      Text(LFLocalizable.Authentication.SetupMfa.recoveryCodeCheckBoxTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      Spacer()
    }
    .padding([.horizontal, .top], 4)
  }
}
