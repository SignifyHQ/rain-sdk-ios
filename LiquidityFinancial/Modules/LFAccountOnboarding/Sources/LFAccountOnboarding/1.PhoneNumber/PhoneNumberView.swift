import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct PhoneNumberView: View {
  @EnvironmentObject
  var environmentManager: EnvironmentManager
  @Environment(\.openURL)
  var openURL
  @Environment(\.presentationMode)
  var presentation
  
  @StateObject private var viewModel = PhoneNumberViewModel()
  
  @FocusState private var keyboardFocus: Field?

  var body: some View {
    VStack(spacing: 16) {
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 120)
        .onTapGesture(count: ViewConstant.magicTapCount) {
          viewModel.onActiveSecretMode()
        }
      phoneNumberView
      voipTermView
      Spacer()
      footerView
    }
    .padding(.horizontal, 30)
    .onChange(of: viewModel.phoneNumber, perform: viewModel.onChangedPhoneNumber)
    .background(Colors.background.swiftUIColor)
    .navigationBarBackButtonHidden()
    .defaultToolBar(icon: .intercom, openIntercom: {
      // TODO: Will be implemeted later
      // intercomService.openIntercom()
    })
    // .track(name: String(describing: type(of: self))) TODO: Will be implemented later
    .navigationLink(isActive: $viewModel.isNavigationToVertificationView) {
      VerificationCodeView(phoneNumber: viewModel.phoneNumber.reformatPhone)
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
  }
}

// MARK: - View Components
private extension PhoneNumberView {
  @ViewBuilder var secretModeView: some View {
    if viewModel.isSecretMode {
      Picker(LFLocalizable.PhoneNumber.Environment.title, selection: $environmentManager.networkEnvironment) {
        Text(NetworkEnvironment.productionLive.rawValue)
          .tag(NetworkEnvironment.productionLive)
        Text(NetworkEnvironment.productionTest.rawValue)
          .tag(NetworkEnvironment.productionTest)
      }
      .pickerStyle(.segmented)
    }
  }
  
  @ViewBuilder var conditionView: some View {
    if viewModel.isShowConditions {
      TextTappable(
        text: LFLocalizable.Term.PrivacyPolicy.description,
        textAlignment: .center,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [viewModel.terms, viewModel.esignConsent, viewModel.privacyPolicy]
      ) { tappedString in
        guard let url = URL(string: viewModel.getURL(tappedString: tappedString)) else { return }
        openURL(url)
      }
      .frame(maxHeight: 50)
    }
  }
  
  var phoneNumberTextField: some View {
    TextFieldWrapper {
      HStack {
        Text(Constants.Default.regionCode.rawValue)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(height: 32)
          .padding(.horizontal, 8)
          .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(4))
        iPhoneNumberField(LFLocalizable.PhoneNumber.TextField.description, text: $viewModel.phoneNumber)
          .placeholderColor(Colors.label.swiftUIColor.opacity(0.75))
          .maximumDigits(ViewConstant.maxDigits)
          .defaultRegion(Constants.Default.region.rawValue)
          .flagHidden(true)
          .foregroundColor(Colors.label.swiftUIColor)
          .focused($keyboardFocus, equals: .phone)
          .frame(
            maxWidth: .infinity,
            minHeight: 44,
            alignment: .center
          )
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              if viewModel.isDisableButton {
                keyboardFocus = .phone
              }
            }
          }
      }
    }
  }
  
  var phoneNumberView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.PhoneNumber.TextField.title.uppercased())
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      phoneNumberTextField
    }
    .padding(.top, 24)
  }
  
  var footerView: some View {
    VStack(spacing: 12) {
      secretModeView
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.isDisableButton,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.isLoading = true
        keyboardFocus = nil
        viewModel.performGetOTP()
      }
      conditionView
    }
    .padding(.bottom, 12)
  }
  
  var voipTermView: some View {
    TextTappable(
      text: LFLocalizable.Term.TermsVoip.description,
      textAlignment: .center,
      fontSize: Constants.FontSize.ultraSmall.value,
      links: [LFLocalizable.Term.PrivacyPolicy.attributeText]
    ) { _ in
      guard let url = URL(string: LFUtility.privacyURL) else { return }
      openURL(url)
    }
    .frame(maxHeight: 90)
  }
}

// MARK: View Constants
private extension PhoneNumberView {
  enum ViewConstant {
    static let maxDigits = 10
    static let magicTapCount = 5
  }
}

// MARK: View Types
private extension PhoneNumberView {
  enum Field: Hashable {
    case phone
  }
}
