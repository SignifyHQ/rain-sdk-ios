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
  
  @StateObject var viewModel: PhoneNumberViewModel
  
  @FocusState private var keyboardFocus: Focus?
  
  @State var openSafariType: PhoneNumberViewModel.OpenSafariType?
  
  public init(
    viewModel: PhoneNumberViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack {
        logoImageView
        phoneNumberView
        
        if viewModel.shouldAgreeToTerms == true {
          promocodeView
        }
        
        Spacer()
        
        footerView
      }
      .simultaneousGesture(
        TapGesture()
          .onEnded {
            keyboardFocus = nil
            viewModel.displayDropdown = false
          }
      )
      
      if viewModel.displayDropdown {
        VStack {
          HStack {
            if #available(iOS 16.0, *) {
              listView()
                .scrollContentBackground(.hidden)
            } else {
              listView()
            }
            
            Spacer()
          }
         Spacer()
        }
      }
    }
    .frame(max: .infinity)
    .padding(.horizontal, 26)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .navigationLink(
      item: $onboardingDestinationObservable.phoneNumberDestinationView
    ) { item in
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
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - Header View Components
private extension PhoneNumberView {
  var logoImageView: some View {
    GenImages.Images.icLogo.swiftUIImage
      .resizable()
      .scaledToFit()
      .frame(120)
      .accessibilityIdentifier(LFAccessibility.PhoneNumber.logoImage)
      .onTapGesture(
        count: ViewConstant.magicTapCount
      ) {
        viewModel.onActiveSecretMode()
      }
      .padding(.bottom, 45)
  }
}

// MARK: - Main Content View Components
private extension PhoneNumberView {
  var phoneNumberView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L10N.Common.PhoneNumber.TextField.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .accessibilityIdentifier(LFAccessibility.PhoneNumber.headerTitle)
      
      phoneNumberTextField
    }
    .padding(.bottom, 16)
  }
  
  var promocodeView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Have a promo code? Enter your code here")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
      
      promocodeTextField
    }
  }
  
  var phoneNumberTextField: some View {
    TextFieldWrapper {
      HStack {
        Text(viewModel.selectedCountry.phoneCode)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(height: 32)
          .padding(.horizontal, 8)
          .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(4))
          .onTapGesture {
            keyboardFocus = nil
            viewModel.displayDropdown = true
          }
        
        iPhoneNumberField(L10N.Common.PhoneNumber.TextField.description, text: $viewModel.phoneNumber)
          .placeholderColor(Colors.label.swiftUIColor.opacity(0.75))
          .maximumDigits(ViewConstant.maxDigits)
          .defaultRegion("US")
          .prefixHidden(false)
          .flagHidden(true)
          .foregroundColor(Colors.label.swiftUIColor)
          .focused($keyboardFocus, equals: .phoneNumber)
          .frame(
            maxWidth: .infinity,
            minHeight: 44,
            alignment: .center
          )
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              if !viewModel.isButtonEnabled {
                keyboardFocus = .phoneNumber
              }
            }
          }
      }
    }
    .accessibilityIdentifier(LFAccessibility.PhoneNumber.textField)
  }
  
  var promocodeTextField: some View {
    TextFieldWrapper {
      TextField(
        "Enter your promo code",
        text: $viewModel.promocode
      )
      .primaryFieldStyle()
      .disableAutocorrection(true)
      .keyboardType(.alphabet)
      .focused($keyboardFocus, equals: .promocode)
    }
  }
  
  func listView() -> some View {
    List(viewModel.countryCodeList, id: \.id) { item in
      Text(item.flagEmoji() + " " + item.phoneCode)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(
          Fonts.regular.swiftUIFont(
            size: Constants.FontSize.small.value
          )
        )
        .onTapGesture {
          viewModel.selectedCountry = item
          viewModel.displayDropdown = false
        }
        .listRowBackground(Colors.secondaryBackground.swiftUIColor)
        .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
        .listRowInsets(.none)
    }
    .cornerRadius(8, style: .continuous)
    .listStyle(.plain)
    .frame(maxWidth: 100, maxHeight: 240)
    .padding(.top, 245)
    .onAppear {
      UITableView.appearance().contentInset.top = -35
      UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    }
    .floatingShadow()
  }
}

// MARK: Footer View Components
private extension PhoneNumberView {
  var footerView: some View {
    VStack(spacing: 5) {
      
      if viewModel.shouldAgreeToTerms == true {
        termsView
      }
      
      secretModeView
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.isLoading = true
        keyboardFocus = nil
        viewModel.displayDropdown = false
        viewModel.performGetOTP()
      }
      .accessibilityIdentifier(LFAccessibility.PhoneNumber.continueButton)
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
  
  @ViewBuilder
  private func checkBoxImage(
    isChecked: Binding<Bool>
  ) -> some View {
    if isChecked.wrappedValue {
      GenImages.Images.termsCheckboxSelected.swiftUIImage
    } else {
      GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
        .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
    }
  }
  
  private var termsView: some View {
    VStack {
      termsLine(text: L10N.Common.Term.EsignConsent.description, isChecked: $viewModel.isEsignAgreed)
      termsLine(text: L10N.Common.Term.AvalancheTerms.description, isChecked: $viewModel.areTermsAgreed)
      termsLine(text: L10N.Common.Term.PrivacyPolicy.description, isChecked: $viewModel.isPrivacyAgreed)
    }
    .padding(.bottom, 5)
  }
  
  private func termsLine(
    text: String,
    isChecked: Binding<Bool>
  ) -> some View {
    HStack(
      alignment: .center,
      spacing: 0
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
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          viewModel.esignConsent,
          viewModel.terms,
          viewModel.privacyPolicy
        ],
        style: .fillColor(Colors.termAndPrivacy.color)
      ) { tappedString in
        switch tappedString {
        case viewModel.esignConsent:
          openSafariType = .consent
        case viewModel.terms:
          openSafariType = .term
        case viewModel.privacyPolicy:
          openSafariType = .privacy
          
        default: break
        }
      }
      .frame(height: 10)
    }
  }
}

// MARK: View Constants
enum ViewConstant {
  static let maxDigits = 11
  static let magicTapCount = 5
}

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

// MARK: - Focus Keyboard
extension PhoneNumberView {
  enum Focus: Int, Hashable {
    case phoneNumber
    case promocode
  }
}
