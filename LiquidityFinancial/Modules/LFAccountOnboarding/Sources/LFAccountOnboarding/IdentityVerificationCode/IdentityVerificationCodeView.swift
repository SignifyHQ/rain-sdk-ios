import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct IdentityVerificationCodeView: View {
  @StateObject private var viewModel: IdentityVerificationCodeViewModel
  @State var selection: Int?
  @State var showIndicator = false
  @FocusState var keyboardFocus: Bool
  
  init(phoneNumber: String, otpCode: String, kind: IdentityVerificationCodeViewModel.Kind) {
    _viewModel = .init(
      wrappedValue: IdentityVerificationCodeViewModel(phoneNumber: phoneNumber, otpCode: otpCode, kind: kind)
    )
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      Text(viewModel.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.top, 12)
      textField
      informationCell
      Spacer()
      continueButton
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 16)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
  }
}

// MARK: - View Components
private extension IdentityVerificationCodeView {
  @ViewBuilder var textField: some View {
    if viewModel.kind == .ssn {
      ssnTextField
    } else {
      passportTextField
    }
  }
  
  var ssnTextField: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextFieldWrapper(errorValue: $viewModel.errorMessage) {
        SecureField("", text: $viewModel.ssn)
          .focused($keyboardFocus)
          .primaryFieldStyle()
          .keyboardType(.numberPad)
          .limitInputLength(
            value: $viewModel.ssn,
            length: Constants.MaxCharacterLimit.ssnLength.value
          )
          .placeholderStyle(
            showPlaceholder: viewModel.ssn.isEmpty,
            placeholder: LFLocalizable.EnterVerificationCode.Last4SSN.placeholder
          )
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              keyboardFocus = true
            }
          }
      }
    }
  }
  
  var passportTextField: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextFieldWrapper(errorValue: $viewModel.errorMessage) {
        SecureField("", text: $viewModel.passport)
          .focused($keyboardFocus)
          .primaryFieldStyle()
          .keyboardType(.numberPad)
          .limitInputLength(
            value: $viewModel.passport,
            length: Constants.MaxCharacterLimit.passportLength.value
          )
          .placeholderStyle(
            showPlaceholder: viewModel.passport.isEmpty,
            placeholder: LFLocalizable.EnterVerificationCode.Last5Passport.placeholder
          )
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              keyboardFocus = true
            }
          }
      }
    }
  }

  var informationCell: some View {
    HStack {
      GenImages.CommonImages.icLock.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      Text(LFLocalizable.EnterVerificationCode.Encrypt.cellText)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: viewModel.isDisableButton,
      isLoading: $viewModel.isLoading
    ) {
      viewModel.login()
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
}
