import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct VerifyCardView: View {
  @StateObject private var viewModel: VerifyCardViewModel
  
  enum Focus {
    case amount
  }
  @FocusState var keyboardFocus: Focus?
  
  init(cardId: String) {
    _viewModel = .init(
      wrappedValue: VerifyCardViewModel(cardId: cardId)
    )
  }
  
  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 8) {
        title
        detail
        amount
      }
      .padding(.horizontal, 30)
      Spacer()
      verifyButton
      contactSupport
    }
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .moveMoney:
        MoveMoneyAccountView(kind: .receive)
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
  }
}

private extension VerifyCardView {
  
  var title: some View {
    Text(LFLocalizable.VerifyCard.title.uppercased())
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.vertical, 15)
  }
  
  var detail: some View {
    Text(LFLocalizable.VerifyCard.detail)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      .padding(.vertical, 15)
  }
  
  var amount: some View {
    VStack(alignment: .leading) {
      header(text: LFLocalizable.VerifyCard.Amount.title)
      cardTextField(
        placeholder: LFLocalizable.VerifyCard.Amount.placeholder,
        value: $viewModel.amount,
        formatters: [
          DecimalFormatter()
        ],
        focus: .amount
      )
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .amount
        }
      }
    }.padding(.top, 16)
  }
 
  var verifyButton: some View {
    FullSizeButton(
      title: LFLocalizable.VerifyCard.Button.verifyCard,
      isDisable: !viewModel.actionEnabled,
      isLoading: $viewModel.loading
    ) {
      viewModel.performAction()
    }
    .padding(.bottom, 12)
    .padding(.horizontal, 30)
  }
  
  var contactSupport: some View {
    FullSizeButton(
      title: LFLocalizable.Button.ContactSupport.title,
      isDisable: false,
      type: .secondary
    ) {
      viewModel.contactSupport()
    }
    .padding(.bottom, 12)
    .padding(.horizontal, 30)
  }
}

private extension VerifyCardView {
  @ViewBuilder
  private func header(text: String) -> some View {
    Text(text)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .opacity(0.75)
  }
  
  @ViewBuilder
  private func cardTextField(
    placeholder: String,
    value: Binding<String>,
    errorValue: Binding<String?>? = nil,
    restriction: TextRestriction = .none,
    formatters: [TextFormatter],
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    TextFieldWrapper(errorValue: errorValue ?? .constant(nil)) {
      FormattingTextField(value: value, formatters: formatters)
        .keyboardType(.decimalPad)
        .modifier(PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder))
        .primaryFieldStyle()
        .autocorrectionDisabled()
        .submitLabel(nextFocus == nil ? .done : .next)
        .focused($keyboardFocus, equals: focus)
        .onSubmit {
          keyboardFocus = nextFocus
        }
    }
  }
}
