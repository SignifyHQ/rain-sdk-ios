import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFFeatureFlags

public struct SecurityHubView: View {
  @StateObject private var viewModel = SecurityHubViewModel()
  @Environment(\.dismiss) private var dismiss
  
  public init() {}
  
  public var body: some View {
    content
      .navigationLink(
        isActive: $viewModel.isChangePasswordFlowPresented
      ) {
        EnterPasswordView(
          purpose: .changePassword,
          isFlowPresented: $viewModel.isChangePasswordFlowPresented
        )
      }
      .navigationLink(
        isActive: $viewModel.isVerifyTOPTFlowPresented
      ) {
        EnterTOTPCodeView(
          purpose: .disableMFA,
          isFlowPresented: $viewModel.isVerifyTOPTFlowPresented
        )
      }
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .setUpMFA:
          SetupAuthenticatorAppView()
        case .verifyEmail:
          VerifyEmailView()
        }
      }
      .onAppear {
        viewModel.onAppear()
      }
  }
}

// MARK: - Private View Components
private extension SecurityHubView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {
        customNavigationBar
        Text(LFLocalizable.Authentication.Security.title.uppercased())
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
        firstSectionView
      }
      .padding(.horizontal, 30)
      .padding(.bottom, 16)
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(
      item: $viewModel.popup,
      dismissAction: {
        viewModel.resetBiometricToggleState()
      },
      content: { item in
        switch item {
        case .biometric:
          setupBiometricsPopup
        case .biometricsLockout:
          biometricLockoutPopup
        case .biometricNotEnrolled:
          biometricNotEnrolledPopup
        }
      })
    .blur(radius: viewModel.popup != nil ? 16 : 0)
    .navigationBarBackButtonHidden()
    .background(Colors.background.swiftUIColor)
  }
  
  var customNavigationBar: some View {
    HStack {
      Button {
        dismiss()
      } label: {
        GenImages.CommonImages.icBack.swiftUIImage
      }
      .padding(.leading, 20)
      Spacer()
    }
    .padding(.horizontal, -30)
  }
  
  var firstSectionView: some View {
    VStack(spacing: 16) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.bottom, 8)
      
      textInformationCell(
        title: LFLocalizable.Authentication.SecurityEmail.title,
        value: viewModel.email.value,
        trailingView: emailRowTrailingView
      )
      
      textInformationCell(
        title: LFLocalizable.Authentication.SecurityPhone.title,
        value: viewModel.phone.value,
        trailingView: textWithAction(
          title: viewModel.phone.status,
          isEnable: false
        ) {
        }
      )
      
      textInformationCell(
        title: LFLocalizable.Authentication.SecurityPassword.title,
        value: Constants.hiddenPassword,
        trailingView: textWithAction(
          title: LFLocalizable.Authentication.SecurityChangePassword.title,
          isEnable: true,
          action: {
            viewModel.isChangePasswordFlowPresented = true
          }
        )
      )
      
      if LFFeatureFlagContainer.isMultiFactorAuthFeatureFlagEnabled {
        textInformationCell(
          title: LFLocalizable.Authentication.SecurityMfa.title,
          value: LFLocalizable.Authentication.SecurityAuthenticationApp.title,
          trailingView: mfaToggleButton
        )
      }
      if viewModel.isBiometricsCapability {
        fullSizeToggleButton(
          title: viewModel.biometricType.title,
          isOn: $viewModel.isBiometricEnabled
        ) {
          viewModel.didBiometricToggleStateChanged()
        }
      }
    }
  }
  
  @ViewBuilder
  var emailRowTrailingView: some View {
    if LFFeatureFlagContainer.isMultiFactorAuthFeatureFlagEnabled {
      textWithAction(
        title: viewModel.shouldVerifyEmail ? LFLocalizable.Authentication.SecurityVerify.title : LFLocalizable.Authentication.SecurityVerified.title,
        isEnable: viewModel.shouldVerifyEmail
      ) {
        viewModel.didTapEmailVerifyButton()
      }
    } else {
      EmptyView()
    }
  }
  
  func textInformationCell<SubContent: View>(
    title: String,
    value: String,
    trailingView: SubContent,
    hasBottomLine: Bool = true
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      HStack {
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        trailingView
      }
      Rectangle()
        .frame(maxWidth: .infinity)
        .frame(height: 1)
        .foregroundColor(
          Colors.label.swiftUIColor.opacity(hasBottomLine ? 0.15 : 0)
        )
    }
  }
  
  func textWithAction(
    title: String,
    isEnable: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button {
      action()
    } label: {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundStyle(
          isEnable
          ? LinearGradient(
            colors: gradientColor,
            startPoint: .leading,
            endPoint: .trailing
          )
          : LinearGradient(
            colors: [Colors.label.swiftUIColor],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .overlay(alignment: .bottom) {
          Rectangle()
            .frame(height: 1)
            .foregroundStyle(
              LinearGradient(
                colors: gradientColor,
                startPoint: .leading,
                endPoint: .trailing
              )
              .opacity(isEnable ? 1 : 0)
            )
            .offset(y: 1)
        }
    }
    .disabled(!isEnable)
  }
  
  func fullSizeToggleButton(title: String, isOn: Binding<Bool>, toggleAction: (() -> Void)?) -> some View {
    HStack {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
      Toggle("", isOn: isOn)
        .toggleStyle(GradientToggleStyle(didToggleStateChange: toggleAction))
    }
    .padding(.horizontal, 16)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(10))
  }
  
  var mfaToggleButton: some View {
    Toggle("", isOn: $viewModel.isMFAEnabled)
      .toggleStyle(
        GradientToggleStyle(didToggleStateChange: {
          viewModel.didMFAToggleStateChange()
        })
      )
  }
  
  var setupBiometricsPopup: some View {
    SetupBiometricPopup(
      biometricType: viewModel.biometricType,
      primaryAction: {
        viewModel.allowBiometricAuthentication()
      },
      secondaryAction: {
        viewModel.declineBiometricAuthentication()
      }
    )
  }
  
  var biometricLockoutPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Authentication.BiometricsLockoutError.title(viewModel.biometricType.title),
      message: LFLocalizable.Authentication.BiometricsLockoutError.message(viewModel.biometricType.title),
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        viewModel.hidePopup()
      }
    )
  }
  
  var biometricNotEnrolledPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Authentication.BiometricsNotEnrolled.title(viewModel.biometricType.title).uppercased(),
      message: LFLocalizable.Authentication.BiometricsNotEnrolled.message(viewModel.biometricType.title),
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        viewModel.hidePopup()
      }
    )
  }
}

// MARK: - View Helpers
private extension SecurityHubView {
  var gradientColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.Gradients.Button.gradientButton0.swiftUIColor,
        Colors.Gradients.Button.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.tertiary.swiftUIColor]
    }
  }
}
