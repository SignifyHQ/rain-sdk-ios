import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFAccessibility
import LFAuthentication
import RainFeature
import RxSwift
import FidesmoCore
import CoreNfcBridge

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
  
  @State private var selectedPage: Int = 0
  @State private var title: String = "Activate Card"
  @State private var logText: String = ""
  @State private var isLoading: Bool = false
  @State private var showSuccess: Bool = false
  
  // App IDs and service IDs for Fidesmo cards
  private let fidesmoPayAppId = "f374c57e"
  private let fidesmoPayInstallServiceId = "install"
  
  private let disposeBag = DisposeBag()
  private let apiDispatcher = FidesmoApiDispatcher(host: "https://api.fidesmo.com", localeStrings: "en")
  @State private var nfcManager: NfcManager?
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Button {
          isPresented = false
        } label: {
          Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        }
      }
      .padding(.horizontal, 24)
      .padding(.top, 24)
      
      if showSuccess {
        successView
      } else if isLoading {
        loadingView
      } else {
        activationView
      }
    }
    .onAppear {
      nfcManager = NfcManager(listener: self)
    }
  }
  
  private var activationView: some View {
    VStack(spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Activate your Limited Edition Card")
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(Colors.label.swiftUIColor)
        
        Text("To activate your card, simply hold your iPhone near the NFC Fidesmo card after tapping the button below.")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 24)
      
      Spacer()
      
      FullSizeButton(title: "Start Activation", isDisable: false, type: .primary) {
        startDelivery()
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
  }
  
  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)
        .padding()
      
      Text("Processing...")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      
      ScrollView {
        Text(logText)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
      }
      .frame(height: 120)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(8)
      .padding(.horizontal, 24)
    }
    .padding(.bottom, 24)
  }
  
  private var successView: some View {
    VStack(spacing: 24) {
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .frame(width: 60, height: 60)
        .foregroundColor(Colors.primary.swiftUIColor)
      
      Text("Card Successfully Activated!")
        .font(Fonts.regular.swiftUIFont(size: 20))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Text("Your limited edition card is now ready to use.")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
        .multilineTextAlignment(.center)
      
      Spacer()
      
      FullSizeButton(title: "Done", isDisable: false, type: .primary) {
        isPresented = false
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .padding(.top, 24)
  }
  
  private func startDelivery() {
    isLoading = true
    logText = "Starting NFC session..."
    nfcManager?.startNfcDiscovery(message: "Hold your iPhone near your Fidesmo card")
  }
  
  private func addToLog(_ message: String) {
    print("log: ", message)
    logText += "\n\(message)"
  }
}

// MARK: - NFC Connection Delegate
extension BottomSheetView: NfcConnectionDelegate {
  func onDeviceConnected(device: NfcDevice) {
    nfcManager?.changeAlertMessage(message: "Card connected, processing...")
    addToLog("Card connected")
    
    // Use the defined appId and serviceId
    startCardActivation(connection: device, appId: fidesmoPayAppId, serviceId: fidesmoPayInstallServiceId)
  }
  
  func startCardActivation(connection: DeviceConnection, appId: String, serviceId: String) {
    addToLog("Starting card activation...")
    
    // Get device description and service details
    connection.getDescription(dispatcher: apiDispatcher)
      .flatMap { deviceDescription -> Observable<DeliveryProgress> in
        addToLog("Card identified: \(deviceDescription.deviceId)")
        
        // Begin delivery process
        return DeliveryManager(connection: Observable.just(connection), dispatcher: apiDispatcher)
          .deliver(appId: appId, 
                   serviceId: serviceId,
                   cin: deviceDescription.cin,
                   publicKey: nil, // The service certificate would normally be retrieved from the service description
                   clientInfo: ClientInfo(clientType: .iphone, applicationName: "LiquidityFinancial"))
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { progress in
        switch progress {
        case .notStarted:
          addToLog("Starting card setup...")
        case let .operationInProgress(_, dataFlow):
          switch dataFlow {
          case .talkingToServer:
            addToLog("Communicating with server...")
          case .toDevice:
            addToLog("Sending commands to card...")
          case .toServer:
            addToLog("Processing card response...")
          }
        case let .finished(status):
          let successMessage = status.success ? "Card activation completed!" : "Card activation failed"
          addToLog(successMessage)
          nfcManager?.changeAlertMessage(message: successMessage)
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            showSuccess = status.success
          }
        default:
          break
        }
      }, onError: { error in
        addToLog("Error: \(error.localizedDescription)")
        nfcManager?.invalidateSession(error: error.localizedDescription)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          isLoading = false
        }
      }, onCompleted: {
        addToLog("Process completed")
      })
      .disposed(by: disposeBag)
  }
  
  func onDeviceDisconnected(device: NfcDevice) {
    addToLog("Card disconnected")
  }
  
  func onWrongTagDetected() {
    addToLog("Wrong card type detected")
    nfcManager?.invalidateSession(error: "This is not a Fidesmo card")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      isLoading = false
    }
  }
  
  func onSessionStarted() {
    addToLog("NFC session started")
  }
  
  func onSessionInvalidated(error: Error?) {
    addToLog("NFC session ended")
    if let error = error {
      addToLog("Error: " + error.localizedDescription)
    }
  }
}
