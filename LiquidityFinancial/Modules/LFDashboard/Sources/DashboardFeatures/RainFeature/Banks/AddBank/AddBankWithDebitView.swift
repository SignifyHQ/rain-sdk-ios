import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import Factory

public struct AddBankWithDebitView: View {
  enum Focus {
    case card
    case cvv
    case exp
  }
  
  @Injected(\.analyticsService) var analyticsService
  
  @FocusState var keyboardFocus: Focus?
  
  @StateObject private var viewModel: AddBankWithDebitViewModel
  
  public init() {
    _viewModel = .init(
      wrappedValue: AddBankWithDebitViewModel()
    )
  }
  
  public var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 24) {
        title
        cardNumber
        HStack(alignment: .top) {
          expiresView
          Spacer(minLength: 25)
          cvvView
        }
      }
      .padding(.horizontal, 30)
      
      Spacer()
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.actionEnabled,
        isLoading: $viewModel.loading
      ) {
        viewModel.performAction()
      }
      .padding(.bottom, 12)
      .padding(.horizontal, 30)
    }
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .verifyCard(let cardId):
        VerifyCardView(cardId: cardId)
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear(perform: {
      analyticsService.track(event: AnalyticsEvent(name: .viewsAddDebitCardScreen))
    })
    .track(name: String(describing: type(of: self)))
  }
  
}

private extension AddBankWithDebitView {
  
  var title: some View {
    Text(L10N.Common.AddBankWithDebit.title)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.vertical, 15)
  }
  
  var cardNumber: some View {
    VStack(alignment: .leading) {
      header(text: L10N.Common.AddBankWithDebit.cardNumber)
      cardTextField(
        placeholder: L10N.Common.AddBankWithDebit.cardNumberPlaceholder,
        value: $viewModel.cardNumber,
        formatters: [
          TextLimitFormatter(limit: Constants.MaxCharacterLimit.cardLength.value),
          RestrictionFormatter(restriction: .numbers),
          CardFormatter()
        ],
        focus: .card,
        nextFocus: .exp
      )
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .card
        }
      }
    }
  }
  
  var expiresView: some View {
    VStack(alignment: .leading) {
      header(text: L10N.Common.AddBankWithDebit.expires)
      textField(
        placeholder: L10N.Common.AddBankWithDebit.expiresPlaceholder,
        value: $viewModel.cardExpiryDate,
        errorValue: $viewModel.dateError,
        formatters: [
          TextLimitFormatter(limit: 7),
          RestrictionFormatter(restriction: .numbers),
          ExpirationFormatter()
        ],
        focus: .exp,
        nextFocus: .cvv
      )
    }
  }
  
  var cvvView: some View {
    VStack(alignment: .leading) {
      header(text: L10N.Common.AddBankWithDebit.cvv)
      textField(
        placeholder: L10N.Common.AddBankWithDebit.cvvPlaceholder,
        value: $viewModel.cardCVV,
        formatters: [
          TextLimitFormatter(limit: 4),
          RestrictionFormatter(restriction: .numbers)
        ],
        focus: .cvv,
        nextFocus: nil,
        isSecure: true
      )
    }
  }
}

private extension AddBankWithDebitView {
  @ViewBuilder
  private func header(text: String) -> some View {
    Text(text)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .opacity(0.75)
  }
  
  @ViewBuilder
  private func textField(
    placeholder: String,
    value: Binding<String>,
    errorValue: Binding<String?>? = nil,
    restriction: TextRestriction = .none,
    formatters: [TextFormatter] = [],
    focus: Focus,
    nextFocus: Focus? = nil,
    isSecure: Bool = false
  ) -> some View {
    TextFieldWrapper(errorValue: errorValue ?? .constant(nil)) {
      FormattingTextField(value: value, formatters: formatters, isSecure: isSecure)
        .keyboardType(.numberPad)
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
  
  @ViewBuilder
  private func cardTextField(
    placeholder: String,
    value: Binding<String>,
    errorValue: Binding<String?>? = nil,
    restriction: TextRestriction = .none,
    formatters: [TextFormatter] = [],
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    TextFieldWrapper(errorValue: errorValue ?? .constant(nil)) {
      FormattingTextField(value: value, formatters: formatters)
        .keyboardType(.numberPad)
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
