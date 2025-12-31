import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct EnterTOTPCodeView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: EnterTOTPCodeViewModel
  
  @Binding var isFlowPresented: Bool
  
  public init(
    purpose: EnterTOTPCodePurpose,
    isFlowPresented: Binding<Bool>
  ) {
    _viewModel = .init(
      wrappedValue: EnterTOTPCodeViewModel(
        purpose: purpose
      )
    )
    _isFlowPresented = .init(projectedValue: isFlowPresented)
  }
  
  public var body: some View {
    content
      .popup(
        item: $viewModel.toastMessage,
        style: .toast
      ) {
        ToastView(toastMessage: $0)
      }
      .padding(.horizontal, 30)
      .padding(.bottom, 16)
      .background(Colors.background.swiftUIColor)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .recoveryCode(purpose):
          RecoveryCodeView(purpose: purpose)
        }
      }
      .defaultToolBar(
        icon: .support,
        openSupportScreen: {
          viewModel.openSupportScreen()
        }
      )
      .navigationBarBackButtonHidden(viewModel.isVerifying)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension EnterTOTPCodeView {
  var content: some View {
    VStack(spacing: 24) {
      Text(L10N.Common.Authentication.EnterTotp.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .padding(.horizontal, 30)
      
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      
      PinCodeView(
        code: $viewModel.totpCode,
        isDisabled: $viewModel.isVerifying,
        codeLength: viewModel.totpCodeLength
      )
      
      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.error.swiftUIColor)
      }
      
      Spacer()
      
      bottomView
    }
  }
  
  var bottomView: some View {
    VStack(spacing: 20) {
      HStack(spacing: 0) {
        Text(L10N.Common.Authentication.EnterTotp.bottomDisclosure)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        Text(L10N.Common.Authentication.EnterTotp.useRecoveryCodeAttributeText)
          .foregroundStyle(
            LinearGradient(
              colors: gradientColor,
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .onTapGesture {
            viewModel.didUseRecoveryCodeLinkTap {
              isFlowPresented = false
            }
          }
          .disabled(viewModel.isVerifying)
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isTOTPCodeEntered,
        isLoading: $viewModel.isVerifying
      ) {
        viewModel.didContinueButtonTap {
          dismiss()
        }
      }
    }
  }
}

// MARK: - View Helpers
private extension EnterTOTPCodeView {
  var gradientColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.gradientButton0.swiftUIColor,
        Colors.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.tertiary.swiftUIColor]
    }
  }
}
