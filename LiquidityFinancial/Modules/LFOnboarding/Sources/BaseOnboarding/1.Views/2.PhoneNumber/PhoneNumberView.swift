import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFAccessibility
import Services
import Combine
import Factory
import EnvironmentService

public struct PhoneNumberView: View {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @Environment(\.presentationMode) var presentation
  @FocusState private var keyboardFocus: Bool
  @StateObject var viewModel: PhoneNumberViewModel
  @State var openSafariType: PhoneNumberViewModel.OpenSafariType?
  
  public init(viewModel: PhoneNumberViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      logoImageView
      phoneNumberView
      voipTermView
      Spacer()
      footerView
    }
    .frame(max: .infinity)
    .onTapGesture {
      keyboardFocus = false
    }
    .overlay(alignment: .topTrailing) {
      supportButton
    }
    .padding(.horizontal, 26)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .navigationLink(item: $onboardingDestinationObservable.phoneNumberDestinationView) { item in
      switch item {
      case let .verificationCode(destinationView):
        destinationView
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear {
      viewModel.onAppear()
    }
    .fullScreenCover(item: $openSafariType) { type in
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
    .navigationBarHidden(true)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - Header View Components
private extension PhoneNumberView {
  var logoImageView: some View {
    VStack {
      Rectangle()
        .fill(.clear)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
      
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(120)
        .accessibilityIdentifier(LFAccessibility.PhoneNumber.logoImage)
        .onTapGesture(count: ViewConstant.magicTapCount) {
          viewModel.onActiveSecretMode()
        }
    }
  }
}
// MARK: - Main Content View Components
private extension PhoneNumberView {
  var phoneNumberView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.PhoneNumber.TextField.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .accessibilityIdentifier(LFAccessibility.PhoneNumber.headerTitle)
      phoneNumberTextField
    }
    .padding(.top, 24)
  }
  
  var phoneNumberTextField: some View {
    TextFieldWrapper {
      HStack {
        Text(Constants.Default.regionCode.rawValue)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(height: 32)
          .padding(.horizontal, 8)
          .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(4))
        iPhoneNumberField(L10N.Common.PhoneNumber.TextField.description, text: $viewModel.phoneNumber)
          .placeholderColor(Colors.label.swiftUIColor.opacity(0.75))
          .maximumDigits(ViewConstant.maxDigits)
          .defaultRegion(Constants.Default.region.rawValue)
          .flagHidden(true)
          .foregroundColor(Colors.label.swiftUIColor)
          .focused($keyboardFocus)
          .frame(
            maxWidth: .infinity,
            minHeight: 44,
            alignment: .center
          )
          .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
              Button("Done") {
                keyboardFocus = false
              }
            }
          }
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              if viewModel.isButtonDisabled {
                keyboardFocus = true
              }
            }
          }
      }
    }
    .accessibilityIdentifier(LFAccessibility.PhoneNumber.textField)
  }
  
  var voipTermView: some View {
    TextTappable(
      text: L10N.Common.Term.TermsVoip.description,
      textAlignment: .center,
      fontSize: Constants.FontSize.ultraSmall.value,
      links: [L10N.Common.Term.PrivacyPolicy.attributeText],
      style: .fillColor(Colors.termAndPrivacy.color)
    ) { _ in
      openSafariType = .privacy
    }
    .accessibilityIdentifier(LFAccessibility.PhoneNumber.voipTermTextTappable)
    .frame(height: 90)
  }
}

// MARK: Footer View Components
private extension PhoneNumberView {
  var footerView: some View {
    VStack(spacing: 5) {
      secretModeView
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: viewModel.isButtonDisabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.isLoading = true
        keyboardFocus = false
        viewModel.performGetOTP()
      }
      .accessibilityIdentifier(LFAccessibility.PhoneNumber.continueButton)
      
      if viewModel.isShowConditions {
        conditionView
      }
    }
    .padding(.bottom, 12)
  }
  
  @ViewBuilder
  var secretModeView: some View {
    if viewModel.isSecretMode {
      Picker(L10N.Common.PhoneNumber.Environment.title, selection: $viewModel.networkEnvironment) {
        Text(NetworkEnvironment.productionLive.rawValue)
          .tag(NetworkEnvironment.productionLive)
        Text(NetworkEnvironment.productionTest.rawValue)
          .tag(NetworkEnvironment.productionTest)
      }
      .pickerStyle(.segmented)
    }
  }
  
  var conditionView: some View {
    TextTappable(
      text: L10N.Common.Term.PrivacyPolicy.description,
      textAlignment: .center,
      fontSize: Constants.FontSize.ultraSmall.value,
      links: [viewModel.terms, viewModel.esignConsent, viewModel.privacyPolicy],
      style: .fillColor(Colors.termAndPrivacy.color)
    ) { tappedString in
      switch tappedString {
      case viewModel.terms: openSafariType = .term
      case viewModel.privacyPolicy: openSafariType = .privacy
      case viewModel.esignConsent: openSafariType = .consent
      default: break
      }
    }
    .accessibilityIdentifier(LFAccessibility.PhoneNumber.conditionTextTappable)
    .frame(height: 50)
  }
}

// MARK: - Overlay Contents
private extension PhoneNumberView {
  var supportButton: some View {
    Button {
      keyboardFocus = false
      DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
        viewModel.openSupportScreen()
      }
    } label: {
      GenImages.CommonImages.icChat.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
    }
    .padding(.top, 28)
    .padding(.leading, 16)
  }
}

// MARK: View Constants
enum ViewConstant {
  static let maxDigits = 10
  static let magicTapCount = 5
}
