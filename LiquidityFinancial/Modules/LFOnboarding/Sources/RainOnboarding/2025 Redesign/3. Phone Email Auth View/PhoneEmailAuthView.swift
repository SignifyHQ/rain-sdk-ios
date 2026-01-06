import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct PhoneEmailAuthView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: PhoneEmailAuthViewModel
  
  @State private var progressBarFrame: CGRect = .zero
  @State private var phoneCodeDropdownFrame: CGRect = .zero
  
  @FocusState private var focusedField: FocusedField?
  
  @State var safariNavigation: PhoneEmailAuthViewModel.SafariNavigation?
  
  private let DROPDOWN_SEARCHBAR_HEIGHT: CGFloat = 52
  private let DROPDOWN_ROW_HEIGHT: CGFloat = 36
  private let DROPDOWN_EMPTY_VIEW_HEIGHT: CGFloat = 50
  // Calculate the country dropdown height based on the number of rows
  private var countryDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.countryList.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_SEARCHBAR_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: phoneCodeDropdownFrame.width * 0.7
      )
  }
  
  public init(
    viewModel: PhoneEmailAuthViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack(
        spacing: 32
      ) {
        if case .signup = viewModel.authType {
          progressView
            .readGeometry { geometry in
              progressBarFrame = geometry.frame(in: .global)
            }
        } else {
          EmptyView()
        }
        
        contentView
        
        Spacer()
        
        if viewModel.shouldDisplayTerms == true {
          termsView
        }
        
        buttonGroup
      }
      .padding(.top, 8)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      // Adding content shape to make sure the whole screen is tappable
      .contentShape(Rectangle())
      .onTapGesture {
        viewModel.isShowingPhoneCodeCountrySelection = false
        focusedField = nil
      }
      
      if viewModel.isShowingPhoneCodeCountrySelection {
        countryDropdownView()
          .frame(
            width: phoneCodeDropdownFrame.width,
            height: countryDropdownHeight,
            alignment: .top
          )
          .background(Colors.backgroundLight.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .position(
            x: phoneCodeDropdownFrame.midX,
            // Calculate the dropdown Y position
            // Adding 8 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: phoneCodeDropdownFrame.maxY - progressBarFrame.minY + countryDropdownHeight / 2 + 8 + 8
          )
      }
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .toast(
      data: $viewModel.currentToast
    )
    .disabled(viewModel.isLoading)
    .fullScreenCover(
      item: $safariNavigation
    ) { type in
      switch type {
      case .consent:
        if let url = viewModel.getURL(tappedString: viewModel.esignConsent) {
          SFSafariViewWrapper(url: url)
        }
      case .term:
        if let url = viewModel.getURL(tappedString: viewModel.terms) {
          SFSafariViewWrapper(url: url)
        }
      case .privacy:
        if let url = viewModel.getURL(tappedString: viewModel.privacyPolicy) {
          SFSafariViewWrapper(url: url)
        }
      }
    }
    // When user is taken to this screen, focus on email or phone input
    .onAppear {
      guard viewModel.currentStep == .input
      else {
        return
      }
      
      focusedField = viewModel.authType.authMethod == .phone ? .phone : .email
    }
    // Stop timer when navigating to another screen
    .onDisappear {
      viewModel.stopTimer()
    }
    // When switching to OTP input step, focus on OTP input
    .onChange(
      of: viewModel.currentStep,
      perform: { newValue in
        if newValue == .verification {
          focusedField = .otp
        }
      }
    )
    // When switching auth method, focus on the correct field
    .onChange(
      of: viewModel.authType.authMethod,
      perform: { newValue in
        focusedField = newValue == .phone ? .phone : .email
      }
    )
    // Hide the dropdown when focusing on an input field
    .onChange(
      of: focusedField,
      perform: { newValue in
        if newValue != nil {
          viewModel.hideSelections()
        }
      }
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        onboardingViewFactory.createView(for: navigation)
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension PhoneEmailAuthView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
      
      if viewModel.currentStep == .verification {
        otpInputView
      } else if viewModel.authType.authMethod == .email {
        emailAddressInputView
      } else if viewModel.authType.authMethod == .phone {
        phoneNumberInputView
      }
    }
    .frame(
      maxWidth: .infinity
    )
    .readGeometry { geometry in
      if case .login = viewModel.authType {
        progressBarFrame = geometry.frame(in: .global)
      }
    }
  }
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(1)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text(viewModel.currentStep == .input ? title : "Enter verification code")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      if viewModel.currentStep == .verification {
        Text("Code sent to \(viewModel.authType.authMethod == .email ? viewModel.emailAddress : (viewModel.selectedCountry.phoneCode + " " +  viewModel.phoneNumber))")
          .foregroundStyle(Colors.titleTertiary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
  
  // TODO: Think of how to best turn these into reusable views
  var phoneNumberInputView: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      Text("Phone number")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      
      HStack(
        alignment: .center,
        spacing: 8
      ) {
        HStack(
          spacing: 3
        ) {
          Text(viewModel.selectedCountryDisplayValue)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          GenImages.Images.icoExpandDown.swiftUIImage
            .resizable()
            .frame(16)
            .rotationEffect(
              .degrees(viewModel.isShowingPhoneCodeCountrySelection ? -180 : 0)
            )
            .animation(
              .easeOut(
                duration: 0.2
              ),
              value: viewModel.isShowingPhoneCodeCountrySelection
            )
        }
        .padding(.vertical, 8)
        .padding(.leading, 8)
        .padding(.trailing, 4)
        .background(Colors.backgroundLight.swiftUIColor)
        .cornerRadius(4)
        .highPriorityGesture(
          TapGesture()
            .onEnded {
              viewModel.isShowingPhoneCodeCountrySelection.toggle()
              focusedField = nil
            }
        )
        
        DefaultTextField(
          placeholder: "(000) 000-0000",
          isDividerShown: false,
          value: $viewModel.phoneNumber,
          keyboardType: .numberPad,
          errorMessage: viewModel.loginErrorMessage == nil ? .constant(nil) : .constant(.empty)
        )
        .focused($focusedField, equals: .phone)
        .onChange(
          of: viewModel.phoneNumber
        ) { newValue in
          DispatchQueue.main.async {
            viewModel.shouldDisplayTerms = nil
            viewModel.phoneNumber = newValue.formatInput(of: .phoneNumber)
          }
        }
      }
      
      Divider()
        .background(viewModel.loginErrorMessage == nil ? Colors.dividerPrimary.swiftUIColor : Colors.accentError.swiftUIColor)
        .frame(
          height: 1,
          alignment: .center
        )
      
      if let errorValue = viewModel.loginErrorMessage {
        Text(errorValue)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.accentError.swiftUIColor)
          .frame(
            maxWidth: .infinity,
            alignment: .leading
          )
      }
    }
    .readGeometry { geometry in
      phoneCodeDropdownFrame = geometry.frame(in: .global)
    }
  }
  
  var emailAddressInputView: some View {
    DefaultTextField(
      title: "Email address",
      placeholder: "Enter email address",
      value: $viewModel.emailAddress,
      keyboardType: .emailAddress,
      autoCapitalization: .never,
      errorMessage: $viewModel.loginErrorMessage
    )
    .focused($focusedField, equals: .email)
    .onChange(
      of: viewModel.emailAddress
    ) { newValue in
      DispatchQueue.main.async {
        viewModel.shouldDisplayTerms = nil
      }
    }
  }
  
  var otpInputView: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      DefaultTextField(
        title: "Enter code",
        placeholder: "000000",
        value: $viewModel.otp,
        keyboardType: .numberPad,
        autoCapitalization: .never,
        errorMessage: $viewModel.otpErrorMessage
      )
      .focused($focusedField, equals: .otp)
      
      if viewModel.isTimerActive && viewModel.otpErrorMessage == nil {
        Text(String(format: "%02d:%02d", 0, viewModel.remainingTime))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
    }
  }
  
  func countryDropdownView(
  ) -> some View {
    VStack(
      spacing: 0
    ) {
      HStack(
        spacing: 4
      ) {
        Image(
          systemName: "magnifyingglass"
        )
        .foregroundColor(Colors.backgroundLight.swiftUIColor)
        
        TextField(
          "Search country",
          text: $viewModel.countrySearchQuery
        )
        .textFieldStyle(PlainTextFieldStyle())
        .submitLabel(.done)
        .tint(Colors.backgroundLight.swiftUIColor)
      }
      .padding(8)
      .background(Colors.backgroundDark.swiftUIColor)
      .cornerRadius(8)
      .padding(8)
      .frame(height: DROPDOWN_SEARCHBAR_HEIGHT)
      
      Divider()
        .background(Colors.backgroundSecondary.swiftUIColor)
      
      List(
        viewModel.countryList,
        id: \.id
      ) { item in
        ZStack {
          HStack(
            spacing: 4
          ) {
            Text(item.flagEmoji())
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .layoutPriority(1)
            
            Text(item.title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .lineLimit(1)
            
            Spacer()
            
            Text(item.phoneCode)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundStyle(Colors.titleSecondary.swiftUIColor)
              .layoutPriority(1)
          }
          
          // Adding clear rectangle to make the whole row tappable, not just the text
          Rectangle()
            .foregroundStyle(
              Color.clear
            )
            .contentShape(Rectangle())
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.zero)
        .onTapGesture {
          viewModel.selectedCountry = item
          viewModel.isShowingPhoneCodeCountrySelection = false
        }
      }
      .environment(\.defaultMinListRowHeight, DROPDOWN_ROW_HEIGHT)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      // Show no results message if the filtered list is empty
      if viewModel.countryList.isEmpty {
        HStack {
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
    }
    .floatingShadow()
  }
  
  private var termsView: some View {
    VStack(
      alignment: .leading,
      spacing: 12
    ) {
      Text("I accept the following terms")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      
      termsLine(text: L10N.Common.Term.EsignConsent.description, isChecked: $viewModel.isEsignAgreed)
      termsLine(text: L10N.Common.Term.AvalancheTerms.description, isChecked: $viewModel.areTermsAgreed)
      termsLine(text: L10N.Common.Term.PrivacyPolicy.description, isChecked: $viewModel.isPrivacyAgreed)
    }
  }
  
  private func termsLine(
    text: String,
    isChecked: Binding<Bool>
  ) -> some View {
    HStack(
      alignment: .center,
      spacing: 8
    ) {
      checkBoxImage(
        isChecked: isChecked
      )
      .onTapGesture {
        isChecked.wrappedValue.toggle()
      }
      
      TextTappable(
        text: text,
        textAlignment: .left,
        verticalTextAlignment: .center,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          viewModel.esignConsent,
          viewModel.terms,
          viewModel.privacyPolicy
        ],
        style: .underlined(Colors.titlePrimary.color)
      ) { tappedString in
        switch tappedString {
        case viewModel.esignConsent:
          safariNavigation = .consent
        case viewModel.terms:
          safariNavigation = .term
        case viewModel.privacyPolicy:
          safariNavigation = .privacy
          
        default: break
        }
      }
    }
    .frame(
      height: 20
    )
  }
  
  @ViewBuilder
  private func checkBoxImage(
    isChecked: Binding<Bool>
  ) -> some View {
    if isChecked.wrappedValue {
      GenImages.Images.icoCheckboxSelected.swiftUIImage
    } else {
      GenImages.Images.icoCheckboxUnselected.swiftUIImage
    }
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 24
    ) {
      if !viewModel.shouldDisplayTerms.falseIfNil {
        Button {
          focusedField = nil
          viewModel.hideSelections()
          
          // Handle the `accout not found` case (switch to signup)
          if viewModel.loginErrorMessage != nil {
            viewModel.onSwitchToSignupButtonTap()
            
            return
          }
          
          viewModel.onSwitchAuthMethodButtonTap()
        } label: {
          Text(toggleMethodButtonTitle.firstLine)
          
          +
          
          Text(
            toggleMethodButtonTitle.secondLine
          )
          .underline()
        }
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundStyle(Colors.titlePrimary.swiftUIColor)
        .multilineTextAlignment(.center)
      }
      
      VStack(
        spacing: 12
      ) {
        FullWidthButton(
          type: .primary,
          title: "Continue",
          isDisabled: !viewModel.isContinueButtonEnabled,
          isLoading: $viewModel.isLoading
        ) {
          focusedField = nil
          viewModel.onContinueButtonTap()
        }
        
        if viewModel.showResendButton && !viewModel.isLoading {
          FullWidthButton(
            type: .alternativeBordered,
            title: "Resend OTP",
            isDisabled: false,
            isLoading: $viewModel.isLoading
          ) {
            focusedField = nil
            viewModel.onResendCodeButtonTap()
          }
        }
      }
    }
  }
}

// MARK: - Helper Methods
extension PhoneEmailAuthView {
  var title: String {
    switch viewModel.authType {
    case .login(let authMethod):
      authMethod == .email ? "Enter your email address" : "Enter your phone number"
    case .signup(let authMethod):
      authMethod == .email ? "Enter your email address to get\nstarted" : "Enter your phone number to get\nstarted"
    }
  }
  
  var toggleMethodButtonTitle: (firstLine: String, secondLine: String) {
    switch viewModel.authType {
    case .login(let authMethod):
      if viewModel.loginErrorMessage != nil {
        return (
          firstLine: "New to Avalanche?\n",
          secondLine: "Sign up here"
        )
      }
      
      return (
        firstLine: "Not able to log in?\n",
        secondLine: authMethod == .phone ? "Log in with email instead" : "Log in with phone number instead"
      )
    case .signup(let authMethod):
      return (
        firstLine: "Not able to sign up?\n",
        secondLine: authMethod == .phone ? "Sign up with email instead" : "Sign up with phone number instead"
      )
    }
  }
}

// MARK: - Private Enums
extension PhoneEmailAuthView {
  enum FocusedField: Hashable {
    case phone
    case email
    case otp
  }
}
