import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct ConfirmRecoveryPinView: View {
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
private extension ConfirmRecoveryPinView {
  var headerView: some View {
    ZStack {
      HStack {
        Button {
          viewModel.isConfirmPinPresented = false
        } label: {
          GenImages.Images.icoArrowNavBack.swiftUIImage
        }
        
        Spacer()
      }
      
      HStack {
        Spacer()
        
        Text("Confirm backup PIN")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
    }
  }
  
  var subtitleView: some View {
    Text("Just making sure that you remember your pin\ncorrectly")
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
        code: $viewModel.confirmPin,
        isSecureInput: true
      )
      .focused($isInputFocused)
      
      Text(viewModel.isPinMismatchDetected ? "PIN does not match, try again" : .empty)
        .foregroundStyle(Colors.accentError.swiftUIColor)
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
        isDisabled: !viewModel.isConfirmButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.onConfirmPinButtonTap()
      }
    }
  }
}
