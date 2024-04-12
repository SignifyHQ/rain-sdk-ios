import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import Factory

public struct PersonalInformationView: View {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @FocusState var keyboardFocus: Focus?
  @StateObject var viewModel: PersonalInformationViewModel
  
  private let onEnterSSN: () -> Void
  
  public init(viewModel: PersonalInformationViewModel, onEnterSSN: @escaping () -> Void) {
    self.onEnterSSN = onEnterSSN
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          contentView
        }
        .onChange(of: keyboardFocus) {
          proxy.scrollTo($0)
        }
        .padding(.horizontal, 30)
      }
      continueButton
    }
    .background(Colors.background.swiftUIColor)
    .navigationTitle("")
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: .init(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(item: $onboardingDestinationObservable.personalInformationDestinationView) { item in
      switch item {
      case .enterSSN(let view):
        view
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        keyboardFocus = .firstName
      }
      viewModel.onAppear()
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension PersonalInformationView {
  var contentView: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.AddPersonalInformation.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.vertical, 16)
      
      textFieldInputView(
        title: L10N.Common.firstName,
        placeholder: L10N.Common.enterFirstName,
        value: $viewModel.firstName,
        restriction: .alphabets,
        keyboardType: .alphabet,
        focus: .firstName,
        nextFocus: .lastName
      )
      
      textFieldInputView(
        title: L10N.Common.lastName,
        placeholder: L10N.Common.enterLastName,
        value: $viewModel.lastName,
        restriction: .alphabets,
        keyboardType: .alphabet,
        focus: .lastName,
        nextFocus: .email
      )
      
      textFieldInputView(
        title: L10N.Common.email,
        placeholder: L10N.Common.enterEmailAddress,
        value: $viewModel.email,
        keyboardType: .emailAddress,
        focus: .email,
        nextFocus: .dob,
        textInputAutocapitalization: .never
      )
      
      Text(L10N.Common.dob)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      DatePickerTextField(
        placeHolderText: L10N.Common.dobFormat,
        value: $viewModel.dateCheck,
        dateValue: $viewModel.dateOfBirth
      )
      .focused($keyboardFocus, equals: .dob)
    }
  }
  
  func textFieldInputView(
    title: String,
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil,
    textInputAutocapitalization: TextInputAutocapitalization = .sentences
  ) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      TextFieldWrapper {
        TextField("", text: value)
          .keyboardType(keyboardType)
          .restrictInput(value: value, restriction: restriction)
          .modifier(
            PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder)
          )
          .primaryFieldStyle()
          .autocorrectionDisabled()
          .limitInputLength(value: value, length: limit)
          .submitLabel(nextFocus == nil ? .done : .next)
          .focused($keyboardFocus, equals: focus)
          .textInputAutocapitalization(textInputAutocapitalization)
          .onSubmit {
            keyboardFocus = nextFocus
          }
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: !viewModel.isActionAllowed
    ) {
      viewModel.onClickedContinueButton {
        onEnterSSN()
      }
    }
    .padding(.bottom, 12)
    .padding(.horizontal, 32)
  }
}

// MARK: - Focus
extension PersonalInformationView {
  enum Focus: Int, Hashable {
    case firstName
    case lastName
    case email
    case dob
  }
}
