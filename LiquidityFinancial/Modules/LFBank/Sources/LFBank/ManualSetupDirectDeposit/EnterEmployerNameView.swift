import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct EnterEmployerNameView: View {
  @StateObject var viewModel: ManualSetupViewModel
  @State private var isNavigateToDepositPaycheck = false
  
  init(achInformation: Binding<ACHModel>) {
    _viewModel = .init(wrappedValue: ManualSetupViewModel(achInformation: achInformation.wrappedValue))
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 30) {
      Text(LFLocalizable.DirectDeposit.EmployerName.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.top, 15)
        .lineLimit(2)
        .lineSpacing(1.7)
        .padding(.trailing, 4)
      employerNameTextField
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.employerName.trimWhitespacesAndNewlines().isEmpty
      ) {
        isNavigateToDepositPaycheck = true
      }
      .padding(.bottom, 16)
    }
    .adaptToKeyboard()
    .padding(.horizontal, 30)
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $isNavigateToDepositPaycheck) {
      PaycheckDepositView(viewModel: viewModel)
    }
  }
}

private extension EnterEmployerNameView {
  var employerNameTextField: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.DirectDeposit.EmployerName.textFieldTitle)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      TextFieldWrapper {
        TextField("", text: $viewModel.employerName)
          .keyboardType(.alphabet)
          .restrictInput(value: $viewModel.employerName, restriction: .alphabets)
          .modifier(
            PlaceholderStyle(showPlaceHolder: $viewModel.employerName.wrappedValue.isEmpty, placeholder: LFLocalizable.DirectDeposit.EmployerName.textFieldPlaceholder)
          )
          .primaryFieldStyle()
          .autocorrectionDisabled()
          .limitInputLength(value: $viewModel.employerName, length: Constants.MaxCharacterLimit.nameLimit.value)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
  }
}
