import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct PersonalInformationView: View {
  @Environment(\.presentationMode) var presentation
  @State var selection: Int?
  @State var showIndicator = false
  @State var toastMessage: String?
  @FocusState var keyboardFocus: Focus?

  private let isAppView: Bool
  @StateObject private var viewModel = PersonalInformationViewModel()

  public init(isAppView: Bool) {
    self.isAppView = isAppView
  }

  public var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(alignment: .leading) {
            Text(LFLocalizable.AddPersonalInformation.title)
              .font(Fonts.Inter.regular.swiftUIFont(size: 18))
              .foregroundColor(Colors.label.swiftUIColor)
              .padding(.vertical, 16)

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
              nextFocus: .dob
            )
          }
        }
        .onChange(of: keyboardFocus) {
          proxy.scrollTo($0)
        }
        .padding(.horizontal, 32)
      }
      VStack {
        FullSizeButton(
          title: LFLocalizable.Button.Continue.title,
          isDisable: !viewModel.isActionAllowed,
          isLoading: $showIndicator
        ) {
          if (viewModel.firstName + " " + viewModel.lastName).count > 23 {
            toastMessage = "name_exceed_message".localizedString
          } else {
            continueTapped()
          }
        }
      }
      .padding(.bottom, 12)
      .padding([.horizontal], 32)

      // TODO: Add EnterSSN view later
      /*
      NavigationLink(destination: EnterSSNView(), tag: 1, selection: $selection) {}
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .padding([.bottom], 5)*/
    }
    .navigationBarBackButtonHidden(showIndicator)
    .background(Colors.background.swiftUIColor)
    .navigationTitle("")
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    // TODO: Add Intercom
    /*
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          intercomService.openIntercom()
        } label: {
          Image(Imagename.chat)
            .foregroundColor(Color.label)
        }
      }
    }
    .onAppear {
      analyticsService.track(event: Event(name: EventName.viewedPersonalInfo.rawValue))
      viewModel.updateUserDetails()
    }
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .track(name: String(describing: type(of: self)))*/
  }

  private var dismissButton: some View {
    Button {
      presentation.wrappedValue.dismiss()
    } label: {
      CircleButton(style: .xmark)
    }
    /*
    Button {
      isAppView ? coordinator.set(route: .dashboard) : presentation.wrappedValue.dismiss()
    } label: {
      if isAppView {
        CircleButton(style: .xmark)
      } else {
        CircleButton(style: .left)
      }
    }*/
  }

  @ViewBuilder
  private func textField(
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil
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
        .onSubmit {
          keyboardFocus = nextFocus
        }
    }
  }

  private func continueTapped() {
    //analyticsService.track(event: Event(name: .personalInfoCompleted))
    callUpdateUserAPI()
  }

  private func callUpdateUserAPI() {
    showIndicator = true
    /*
    viewModel.callSubmitAPI { _, status, error in
      showIndicator = false
      if status == true {
        selection = 1
      } else {
        DispatchQueue.main.async {
          toastMessage = error?.localizedDescription ?? ""
        }
      }
    }*/
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
