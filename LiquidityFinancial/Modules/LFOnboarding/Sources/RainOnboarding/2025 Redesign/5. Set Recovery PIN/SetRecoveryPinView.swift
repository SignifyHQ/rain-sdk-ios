import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct SetRecoveryPinView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: SetRecoveryPinViewModel
  
  @FocusState private var isInputFocused: Bool
  
  public init(
    viewModel: SetRecoveryPinViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      progressView
      
      contentView
      
      Spacer()
      
      buttonGroup
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundPrimary.swiftUIColor)
    .onTapGesture {
      isInputFocused = false
    }
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      },
      isBackButtonHidden: true
    )
    .toast(
      data: $viewModel.currentToast
    )
    .disabled(viewModel.isLoading)
    .onAppear {
      isInputFocused = true
    }
    .sheetWithContentHeight(
      isPresented: $viewModel.isConfirmPinPresented,
      content: {
        ConfirmRecoveryPinView(
          viewModel: viewModel
        )
        .presentationDragIndicator(.hidden)
        .onAppear {
          viewModel.confirmPin = .empty
        }
      }
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        onboardingViewFactory.createView(for: navigation)
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension SetRecoveryPinView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView

      otpInputView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(3)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text("Secure your wallet with a PIN")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Text("Your account is backed up to iCloud for easy\nrecovery. Add a PIN for extra protection.")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var otpInputView: some View {
    VStack(
      alignment: .center,
      spacing: 12
    ) {
      OTPField(
        code: $viewModel.pin,
        isSecureInput: true
      )
      .focused($isInputFocused)
      
      Text("Keep your backup PIN secure")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: "Continue",
        isDisabled: !viewModel.isContinueButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        isInputFocused = false
        viewModel.onContinueButtonTap()
      }
    }
  }
}

// MARK: - Private Enums
extension SetRecoveryPinView {}
