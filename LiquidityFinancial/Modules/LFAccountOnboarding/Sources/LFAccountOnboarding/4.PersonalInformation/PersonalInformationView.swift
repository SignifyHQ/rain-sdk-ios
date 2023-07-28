import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct PersonalInformationView: View {
  
  @State var toastMessage: String?
  @FocusState var keyboardFocus: Focus?
  
  @StateObject private var viewModel = PersonalInformationViewModel()

  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          contentView
        }
        .onChange(of: keyboardFocus) {
          proxy.scrollTo($0)
        }
        .padding(.horizontal, 32)
      }
      VStack {
        FullSizeButton(
          title: LFLocalizable.Button.Continue.title,
          isDisable: !viewModel.isActionAllowed
        ) {
          if (viewModel.firstName + " " + viewModel.lastName).count > 23 {
            toastMessage = "name_exceed_message".localizedString
          } else {
            viewModel.isNavigationToSSNView = true
          }
        }
      }
      .padding(.bottom, 12)
      .padding([.horizontal], 32)
    }
    .background(Colors.background.swiftUIColor)
    .navigationTitle("")
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(isActive: $viewModel.isNavigationToSSNView) {
      EnterSSNView()
    }
    // TODO: Add track event
    //    .onAppear {
    //      analyticsService.track(event: Event(name: EventName.viewedPersonalInfo.rawValue))
    //    }
    //    .track(name: String(describing: type(of: self)))
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
      Text(LFLocalizable.AddPersonalInformation.title.uppercased())
        .font(Fonts.Inter.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.vertical, 16)
        .onTapGesture {
          viewModel.magicFillAccount()
        }
      
      Text(LFLocalizable.firstName)
        .font(Fonts.Inter.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
      textField(
        placeholder: LFLocalizable.enterFirstName,
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
      
      Text(LFLocalizable.lastName)
        .font(Fonts.Inter.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      textField(
        placeholder: LFLocalizable.enterLastName,
        value: $viewModel.lastName,
        restriction: .alphabets,
        keyboardType: .alphabet,
        focus: .lastName,
        nextFocus: .email
      )
      
      Text(LFLocalizable.email)
        .font(Fonts.Inter.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      textField(
        placeholder: LFLocalizable.enterEmailAddress,
        value: $viewModel.email,
        keyboardType: .emailAddress,
        focus: .email,
        nextFocus: .dob,
        textInputAutocapitalization: .never
      )
      
      Text(LFLocalizable.dob)
        .font(Fonts.Inter.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 24)
      DatePickerTextField(
        placeHolderText: LFLocalizable.dobFormat,
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

#if DEBUG
struct PersonalInformationView_Previews: PreviewProvider {
  static var previews: some View {
    PersonalInformationView()
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
