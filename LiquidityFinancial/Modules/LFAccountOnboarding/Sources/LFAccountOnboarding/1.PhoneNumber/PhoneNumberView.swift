import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFServices
import Combine

struct PhoneNumberView: View {
  @EnvironmentObject
  var environmentManager: EnvironmentManager
  @Environment(\.openURL)
  var openURL
  @Environment(\.presentationMode)
  var presentation
  
  @StateObject private var viewModel = PhoneNumberViewModel()
  
  @FocusState private var keyboardFocus: Bool
  
  var body: some View {
    ZStack {
      VStack {
        Rectangle()
          .fill(.clear)
          .frame(maxWidth: .infinity)
          .frame(height: 60)
        
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
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onTapGesture {
      keyboardFocus = false
    }
    .overlay(alignment: .topTrailing, content: {
        Button {
          keyboardFocus = false
          DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            viewModel.openIntercom()
          }
        } label: {
          GenImages.CommonImages.icChat.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
        .padding(.top, 28)
        .padding(.leading, 16)
    })
    .padding(.horizontal, 26)
    .onChange(of: viewModel.phoneNumber, perform: viewModel.onChangedPhoneNumber)
    .background(Colors.background.swiftUIColor)
    .navigationBarBackButtonHidden()
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case let .verificationCode(requiredAuth):
          VerificationCodeView(
            phoneNumber: viewModel.phoneNumber.reformatPhone,
            requiredAuth: requiredAuth
          )
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationBarHidden(true)
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
  
  @ViewBuilder
  var conditionView: some View {
    TextTappable(
      text: LFLocalizable.Term.PrivacyPolicy.description,
      textAlignment: .center,
      fontSize: Constants.FontSize.ultraSmall.value,
      links: [viewModel.terms, viewModel.esignConsent, viewModel.privacyPolicy],
      style: .fillColor(Colors.termAndPrivacy.color)
    ) { tappedString in
      guard let url = URL(string: viewModel.getURL(tappedString: tappedString)) else { return }
      openURL(url)
    }
    .frame(height: 50)
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
        iPhoneNumberField(LFLocalizable.PhoneNumber.TextField.description, text: $viewModel.phoneNumber)
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
              if viewModel.isDisableButton {
                keyboardFocus = true
              }
            }
          }
      }
    }
  }
  
  var phoneNumberView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.PhoneNumber.TextField.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      phoneNumberTextField
    }
    .padding(.top, 24)
  }
  
  @ViewBuilder
  var footerView: some View {
    VStack(spacing: 12) {
      secretModeView
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.isDisableButton,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.isLoading = true
        keyboardFocus = false
        viewModel.performGetOTP()
      }
      conditionView
    }
    .padding(.bottom, 12)
  }
  
  @ViewBuilder
  var voipTermView: some View {
    TextTappable(
      text: LFLocalizable.Term.TermsVoip.description,
      textAlignment: .center,
      fontSize: Constants.FontSize.ultraSmall.value,
      links: [LFLocalizable.Term.PrivacyPolicy.attributeText],
      style: .fillColor(Colors.termAndPrivacy.color)
    ) { _ in
      guard let url = URL(string: LFUtility.privacyURL) else { return }
      openURL(url)
    }
    .frame(height: 90)
  }
}

  // MARK: View Constants
private extension PhoneNumberView {
  enum ViewConstant {
    static let maxDigits = 10
    static let magicTapCount = 5
  }
}

#if DEBUG
struct PhoneNumberView_Previews: PreviewProvider {
  static var previews: some View {
    PhoneNumberView()
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
