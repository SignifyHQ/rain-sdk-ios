import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountData
import Services

public struct PinCodeBackupView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: PinCodeBackupViewModel
  @FocusState private var isFocused: Bool
  
  private let onBack: (() -> Void)?
  private let onContinue: ((String) -> Void)?
  
  public init(
    purpose: PinCodeBackupViewModel.Purpose,
    onBack: (() -> Void)? = nil,
    onContinue: ((String) -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: PinCodeBackupViewModel(purpose: purpose)
    )
    self.onBack = onBack
    self.onContinue = onContinue
  }
  
  public var body: some View {
    content
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension PinCodeBackupView {
  var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      headerView
      pinCodeView
      bottomButtonView
    }
    .padding([.horizontal, .top], 24)
    .background(Colors.grey900.swiftUIColor)
  }
  
  var pinCodeView: some View {
    VStack(spacing: 12) {
      OTPField(
        code: $viewModel.pinCode,
        digitCount: viewModel.pinCodeLength,
        isSecureInput: true
      )
      .focused($isFocused)
      .onAppear {
        isFocused = true
      }
      
      if let successMessage = viewModel.successInlineMessage {
        Text(successMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.successDefault.swiftUIColor)
      } else if let errorMessage = viewModel.errorInlineMessage {
        Text(errorMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.red400.swiftUIColor)
      } else {
        Text(L10N.Common.WalletBackup.UpdatePin.InputNewPin.note)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textTertiary.swiftUIColor)
      }
    }
    .padding(.horizontal, 32)
  }
  
  var headerView: some View {
    VStack(alignment: .leading, spacing: 12) {
      ZStack(alignment: .leading) {
        Button {
          if viewModel.successInlineMessage != nil || viewModel.purpose == .enterNewPin {
            dismiss()
            return
          }
          
          onBack?()
        } label: {
          Image(systemName: "arrow.left")
            .font(.title2)
            .foregroundColor(Colors.iconPrimary.swiftUIColor)
        }
        
        Text(L10N.Common.WalletBackup.UpdatePin.Popup.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .frame(maxWidth: .infinity)
          .multilineTextAlignment(.center)
      }
      
      Text(viewModel.purpose.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
  }
  
  var bottomButtonView: some View {
    FullWidthButton(
      title: L10N.Common.Common.Continue.Button.title,
      isDisabled: viewModel.isButtonDisable,
      isLoading: $viewModel.isLoading
    ) {
      if viewModel.successInlineMessage != nil {
        dismiss()
        return
      }
      
      viewModel.onContinueButtonTap { pin in
        onContinue?(pin)
      }
    }
  }
}
