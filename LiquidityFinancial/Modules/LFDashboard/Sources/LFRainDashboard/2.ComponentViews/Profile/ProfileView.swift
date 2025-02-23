import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFAccessibility
import LFAuthentication
import RainFeature

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @Environment(\.scenePhase) var scenePhase
  
  @State private var isFidesmoFlowPresented = false
  @State private var sheetHeight: CGFloat = 380
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 24) {
        contact
        accountSettings
        bottom
      }
      .padding([.top, .horizontal], 30)
    }
    .frame(maxWidth: .infinity)
    .blur(radius: viewModel.popup != nil ? 16 : 0)
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(L10N.Common.Profile.Toolbar.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
    .navigationBarHidden(viewModel.popup != nil)
    .overlay(popupBackground)
    .onAppear {
      viewModel.onAppear()
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkNotificationsStatus()
      }
    })
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .depositLimits:
        AccountLimitsView()
      case .referrals:
        ReferralsView()
      case .securityHub:
        SecurityHubView()
      }
    }
    .popup(item: $viewModel.popup) { popup in
      switch popup {
      case .deleteAccount:
        deleteAccountPopup
      case .logout:
        logoutPopup
      }
    }
    .sheet(
      isPresented: $isFidesmoFlowPresented
    ) {
      BottomSheetView(
        isPresented: $isFidesmoFlowPresented,
        sheetHeight: $sheetHeight
      )
      .onAppear(
        perform: {
          sheetHeight = 380
        }
      )
      .presentationDetents([.height(sheetHeight)])
      .interactiveDismissDisabled(true)
    }
  }
}

// MARK: - View Components
private extension ProfileView {
  @ViewBuilder var popupBackground: some View {
    if viewModel.popup != nil {
      Colors.background.swiftUIColor.opacity(0.5).ignoresSafeArea()
    }
  }
  
  var contact: some View {
    VStack(spacing: 16) {
      userImage
      VStack(spacing: 4) {
        Text(viewModel.name)
          .font(Fonts.regular.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(viewModel.email)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
    }
  }
  
  var userImage: some View {
    ZStack {
      Circle()
        .fill(Colors.secondaryBackground.swiftUIColor)
        .frame(80)
        .overlay {
          GenImages.CommonImages.icUser.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      Circle()
        .stroke(
          Colors.primary.swiftUIColor,
          style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )
        .frame(92)
        .padding(1)
    }
  }
  
  var accountSettings: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.Profile.Accountsettings.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .padding(.leading, 10)
      VStack(spacing: 10) {
        informationCell(
          image: GenImages.CommonImages.icPhone.swiftUIImage,
          title: L10N.Common.Profile.PhoneNumber.title,
          value: viewModel.phoneNumber
        )
        informationCell(
          image: GenImages.CommonImages.icMail.swiftUIImage,
          title: L10N.Common.Profile.Email.title,
          value: viewModel.email
        )
        informationCell(
          image: GenImages.CommonImages.icMap.swiftUIImage,
          title: L10N.Common.Profile.Address.title,
          value: viewModel.address
        )
        ArrowButton(image: GenImages.CommonImages.icQuestion.swiftUIImage, title: L10N.Common.Profile.Help.title, value: nil) {
          viewModel.helpTapped()
        }
        if !viewModel.notificationsEnabled {
          ArrowButton(
            image: GenImages.CommonImages.icNotification.swiftUIImage,
            title: L10N.Common.Profile.Notifications.title,
            value: nil
          ) {
            viewModel.notificationTapped()
          }
        }
        ArrowButton(
          image: GenImages.CommonImages.icHomeCards.swiftUIImage,
          title: "Activate Limited edition card ✨",
          value: nil
        ) {
          DispatchQueue.main.async {
            isFidesmoFlowPresented = true
          }
        }
      }
    }
  }
  
  var bottom: some View {
    VStack(spacing: 16) {
      VStack(spacing: 10) {
        FullSizeButton(title: L10N.Common.Profile.Logout.title, isDisable: false, type: .secondary) {
          viewModel.logoutTapped()
        }
        .accessibilityIdentifier(LFAccessibility.ProfileScreen.logoutButton)
        HStack {
          Rectangle()
            .fill(Colors.label.swiftUIColor.opacity(0.5))
            .frame(height: 1)
          Text(L10N.Common.Profile.Or.title)
            .font(Fonts.regular.swiftUIFont(size: 10))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
          Rectangle()
            .fill(Colors.label.swiftUIColor.opacity(0.5))
            .frame(height: 1)
        }
        .padding(.horizontal, 12)
        FullSizeButton(title: L10N.Common.Profile.DeleteAccount.title, isDisable: false, type: .destructive) {
          viewModel.deleteAccountTapped()
        }
      }
      Text(L10N.Common.Profile.Version.title(LFUtilities.marketingVersion))
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
    .padding(.vertical, 16)
  }
  
  var deleteAccountPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Profile.DeleteAccount.message.uppercased(),
      primary: .init(text: L10N.Common.Button.Yes.title, action: { viewModel.deleteAccount() }),
      secondary: .init(text: L10N.Common.Button.No.title, action: { viewModel.dismissPopup() })
    )
  }
  
  var logoutPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Profile.Logout.message.uppercased(),
      primary: .init(text: L10N.Common.Button.Yes.title, action: { viewModel.logout() }),
      secondary: .init(text: L10N.Common.Button.No.title, action: { viewModel.dismissPopup() }),
      isLoading: $viewModel.isLoading
    )
  }
  
  func informationCell(image: Image, title: String, value: String) -> some View {
    HStack(spacing: 12) {
      image
        .foregroundColor(Colors.label.swiftUIColor)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 10))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.trailing, 24)
      }
      .lineLimit(2)
      .minimumScaleFactor(0.6)
      Spacer()
    }
    .padding(12)
    .padding(.leading, 6)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}

struct BottomSheetView: View {
  @Binding var isPresented: Bool
  @Binding var sheetHeight: CGFloat
  
  @State var selectedPage: Int = 0 {
    didSet {
      sheetHeight = pages[selectedPage].height
      title = pages[selectedPage].title
    }
  }
  
  @State private var title: String = "Let's get started"
  @State private var keyboardHeight: CGFloat = 0
  
  private var pages: [any SheetPage] {
    [
      FidesmoStepOne(onNext: { selectedPage = 1 }),
      FidesmoStepTwo(onNext: { selectedPage = 2 }, onCancel: { isPresented = false }),
      FidesmoStepThree(onNext: { selectedPage = 3 }, onCancel: { isPresented = false }),
      FidesmoStepFour(onNext: { selectedPage = 4 }, onCancel: { isPresented = false }),
      FidesmoStepFive(onNext: { selectedPage = 5 }, onCancel: { isPresented = false }),
      FidesmoStepSix(onNext: { isPresented = false })
    ]
  }
  
  private var pageViews: [AnyView] {
    pages.map { AnyView($0) }
  }
  
  var body: some View {
    VStack {
      header
      pageViews[selectedPage]
    }
    .padding(.top, 25)
    .padding(.bottom, 5)
    .padding(.horizontal, 25)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .background(Color(hex: "#09080A"))
    .onAppear {
      observeKeyboardNotifications()
    }
    .onDisappear {
      NotificationCenter.default.removeObserver(self)
    }
  }
  
  private var header: some View {
    HStack {
      if pages[selectedPage].shouldShowBackButton {
        Button(
          action: {
            guard selectedPage != 0
            else {
              isPresented = false
              return
            }
            
            selectedPage -= 1
          }
        ) {
          Image(
            systemName: "arrow.left"
          )
          .font(.title2)
          .foregroundColor(.primary)
        }
      }
      
      Spacer()
      
      Text(title)
        .font(Fonts.semiBold.swiftUIFont(size: 20))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .center)
      
      Spacer()
    }
  }
  
  private func observeKeyboardNotifications() {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
      if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
        withAnimation(.easeInOut) {
          keyboardHeight = keyboardFrame.height
        }
      }
    }
    
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
      withAnimation(.easeInOut) {
        keyboardHeight = 0
      }
    }
  }
}

struct FidesmoStepOne: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 380
  var title: String = "Let's get started"
  
  let onNext: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      GenImages.CommonImages.icAvalancheFidesmo.swiftUIImage
        .padding(.vertical, 25)
      
      Text("Connect your Limited edition Avalanche Card to enjoy secure and seamless contactless payments.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      TextTappable(
        text: "By tapping Next you agree to the Fidesmo Terms and Conditions.",
        textAlignment: .left,
        textColor: Colors.label.color.withAlphaComponent(0.75),
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          "Fidesmo Terms and Conditions"
        ],
        style: .fillColor(Colors.termAndPrivacy.color)
      ) { tappedString in
        switch tappedString {
        default:
          break
        }
      }
      .accessibilityIdentifier(LFAccessibility.PhoneNumber.conditionTextTappable)
      .frame(height: 50)
      .padding(.bottom, 0)
      
      FullSizeButton(
        title: "Next",
        isDisable: false
      ) {
        onNext()
      }
    }
  }
}


struct FidesmoStepTwo: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 350
  var title: String = "Let’s connect your card"
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      Button {
        onNext()
      } label: {
        GenImages.CommonImages.icConnectNfc.swiftUIImage
      }
      .padding(.vertical, 25)
      
      Text("Tap the connect button to begin the process.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      FullSizeButton(
        title: "Cancel",
        isDisable: false,
        type: .tertiary
      ) {
        onCancel()
      }
    }
  }
}

struct FidesmoStepThree: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 350
  var title: String = "Ready to Scan"
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      Button {
        onNext()
      } label: {
        GenImages.CommonImages.icNfc.swiftUIImage
      }
      .padding(.vertical, 25)
      
      Text("Hold your card against the top edge of the back of your phone.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      FullSizeButton(
        title: "Cancel",
        isDisable: false,
        type: .tertiary
      ) {
        onCancel()
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct FidesmoStepFour: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 550
  var title: String = "Activation"
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      Text("How would you like to activate your payment card?")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.top, 20)
      
      GenImages.CommonImages.unavailableCard.swiftUIImage
        .padding(.vertical, 25)
      
      Spacer()
      
      FullSizeButton(
        title: "Receive SMS code on *******4304",
        isDisable: false,
        type: .tertiary
      ) {
        onNext()
      }
      
      FullSizeButton(
        title: "Receive code to ch***@raincards.xyz",
        isDisable: false,
        type: .tertiary
      ) {
        onNext()
      }
      
      FullSizeButton(
        title: "Activate later",
        isDisable: false,
        type: .alternative
      ) {
        //onCancel()
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct FidesmoStepFive: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 650
  var title: String = "Activation code"
  
  @FocusState private var isTextFieldFocused: Bool
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  @State var error: String? = nil
  @State var otp: String = ""
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .center) {
          Text("Enter the activation code received by SMS to *******4304 from your bank the code is valid for 30 minutes.")
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .lineSpacing(1.2)
            .font(Fonts.regular.swiftUIFont(size: 18))
            .foregroundColor(Colors.label.swiftUIColor)
            .padding(.top, 20)
          
          GenImages.CommonImages.unavailableCard.swiftUIImage
            .padding(.vertical, 25)
          
          Spacer()
          
          TextFieldWrapper(errorValue: $error) {
            TextField(
              "Activation code",
              text: $otp
            )
            .limitInputLength(value: $otp, length: 6)
            .primaryFieldStyle()
            .disableAutocorrection(true)
            .keyboardType(.numberPad)
            .focused($isTextFieldFocused)
          }
          
          FullSizeButton(
            title: "Next",
            isDisable: false,
            type: .tertiary
          ) {
            onNext()
            isTextFieldFocused = false
          }
          
          FullSizeButton(
            title: "Resend code",
            isDisable: false,
            type: .tertiary
          ) {
            //onNext()
          }
          
          FullSizeButton(
            title: "Activate later",
            isDisable: false,
            type: .alternative
          ) {
            //onCancel()
          }
        }
        .frame(minHeight: geometry.size.height)
      }
      .frame(maxHeight: .infinity)
      .scrollIndicators(.hidden)
    }
  }
}

struct FidesmoStepSix: SheetPage {
  var shouldShowBackButton: Bool = false
  var height: CGFloat = 350
  var title: String = "Finished!"
  
  let onNext: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      GenImages.CommonImages.icLogo.swiftUIImage
      .padding(.vertical, 25)
      
      Text("CARD ACTIVATED")
        .frame(maxWidth: .infinity, alignment: .center)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 26))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      FullSizeButton(
        title: "Done",
        isDisable: false,
        type: .alternative
      ) {
        onNext()
      }
    }
    .frame(maxWidth: .infinity)
  }
}

protocol SheetPage: View {
  var shouldShowBackButton: Bool { get }
  var height: CGFloat { get }
  var title: String { get }
}
