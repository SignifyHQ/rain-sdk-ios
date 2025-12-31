import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct WalletRecoveryPinView: View {
  @StateObject var viewModel: WalletRecoveryViewModel
  
  @FocusState private var isInputFocused: Bool
  
  public init(
    viewModel: WalletRecoveryViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      headerView
      
      subtitleView
      
      otpInputView
      
      buttonGroup
    }
    .padding(.top, 24)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundDark.swiftUIColor)
    .onAppear {
      isInputFocused = true
    }
  }
}

// MARK: - View Components
private extension WalletRecoveryPinView {
  var headerView: some View {
    ZStack {
      HStack {
        Button {
          viewModel.isEnterPinPresented = false
          viewModel.isPinRecoveryRunning = false
        } label: {
          GenImages.Images.icoArrowNavBack.swiftUIImage
        }
        
        Spacer()
      }
      
      HStack {
        Spacer()
        
        Text("Enter your backup PIN")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
    }
  }
  
  var subtitleView: some View {
    Text("We need to make sure it’s you who’s trying to\nrecover your account")
      .foregroundStyle(Colors.titlePrimary.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
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
    }
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: "Confirm PIN",
        isDisabled: !viewModel.isContinueButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.onConfirmPinButtonTap()
      }
    }
  }
}
