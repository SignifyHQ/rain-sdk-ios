import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import Factory

public struct PersonalInformationView: View {
  
  @State
  var toastMessage: String?
  @FocusState
  var keyboardFocus: Focus?
  @Injected(\.analyticsService)
  var analyticsService
  
  @StateObject
  var viewModel: PersonalInformationViewModel

  @InjectedObject(\.onboardingDestinationObservable)
  var onboardingDestinationObservable
  
  let onEnterSSN: () -> Void
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
      VStack {
        FullSizeButton(
          title: L10N.Common.Button.Continue.title,
          isDisable: !viewModel.isActionAllowed
        ) {
          if (viewModel.firstName + " " + viewModel.lastName).count > 23 {
            toastMessage = "name_exceed_message".localizedString
          } else {
            analyticsService.track(event: AnalyticsEvent(name: .personalInfoCompleted))
            onEnterSSN()
          }
        }
      }
      .padding(.bottom, 12)
      .padding([.horizontal], 32)
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
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(item: $onboardingDestinationObservable.personalInformationDestinationView, destination: { item in
      switch item {
      case .enterSSN(let view):
        view
      }
    })
    .onAppear(perform: {
      analyticsService.track(event: AnalyticsEvent(name: .viewedPersonalInfo))
    })
    .track(name: String(describing: type(of: self)))
  }
  
  @ViewBuilder
  private func textField(
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil,
    textInputAutocapitalization: TextInputAutocapitalization = .sentences
  ) -> some View {
    TextFieldWrapper {
      TextField("", text: value)
        .keyboardType(keyboardType)
        .restrictInput(value: value, restriction: restriction)
        .modifier(PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder))
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
  
  private var contentView: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.AddPersonalInformation.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.vertical, 16)
      
      Text(L10N.Common.firstName)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
      textField(
        placeholder: L10N.Common.enterFirstName,
        value: $viewModel.firstName,
        restriction: .alphabets,
        keyboardType: .alphabet,
        focus: .firstName,
        nextFocus: .lastName
      ).onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .firstName
        }
      }
      
      Text(L10N.Common.lastName)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      textField(
        placeholder: L10N.Common.enterLastName,
        value: $viewModel.lastName,
        restriction: .alphabets,
        keyboardType: .alphabet,
        focus: .lastName,
        nextFocus: .email
      )
      
      Text(L10N.Common.email)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      textField(
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
        dateValue: $viewModel.dob
      ).focused($keyboardFocus, equals: .dob)
    }
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
