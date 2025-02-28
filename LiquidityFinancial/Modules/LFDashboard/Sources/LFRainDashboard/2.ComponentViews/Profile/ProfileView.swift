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
import CoreNFC
import Factory
import RainDomain
import Services

// String extension for card formatting
extension String {
  func insertSpaces(afterEvery n: Int) -> String {
    var result = ""
    for (index, character) in self.enumerated() {
      if index > 0 && index % n == 0 {
        result += " "
      }
      result.append(character)
    }
    return result
  }
}

// Define minimal protocols for what we need
// Remove our protocol definition that's causing the issue
// protocol RainCardRepositoryProtocol {}

// RainCardEntity definition
struct RainCardEntity {
  let cardId: String?
  let last4: String?
  let cardStatus: String
  let expMonth: String?
  let expYear: String?
}

// Define CardMetaData struct since we can't import it directly
struct CardMetaData: Equatable {
  let pan: String
  let cvv: String
  
  var panFormatted: String {
    pan.insertSpaces(afterEvery: 4)
  }
  
  init(pan: String, cvv: String) {
    self.pan = pan
    self.cvv = cvv
  }
}

// Define RainCardSecretInformationEntity struct since we can't import it directly
struct RainCardSecretInformationEntity {
  struct EncryptedEntity {
    let iv: String
    let data: String
    
    init(iv: String, data: String) {
      self.iv = iv
      self.data = data
    }
  }
  
  let encryptedPanEntity: EncryptedEntity
  let encryptedCVCEntity: EncryptedEntity
  
  init(encryptedPanEntity: EncryptedEntity, encryptedCVCEntity: EncryptedEntity) {
    self.encryptedPanEntity = encryptedPanEntity
    self.encryptedCVCEntity = encryptedCVCEntity
  }
}

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @Environment(\.scenePhase) var scenePhase
  
  @State private var isFidesmoFlowPresented = false
  @State private var sheetHeight: CGFloat = 380
  
  // Track the connection state
  @State private var currentConnection: NfcDevice?
  
  private let apiDispatcher = FidesmoApiDispatcher(host: "https://api.fidesmo.com", localeStrings: "en")
  
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
      .environmentObject(viewModel)
      .onAppear(
        perform: {
          sheetHeight = 380
        }
      )
      .presentationDetents([.height(CGFloat(sheetHeight))])
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

// Now the BottomSheetView is a public struct directly under the main file, not nested in ProfileView
struct BottomSheetView: View {
  @Binding var isPresented: Bool
  @Binding var sheetHeight: CGFloat
  
  @EnvironmentObject var viewModel: ProfileViewModel
  
  // Use an observable object to hold mutable state that would otherwise require lazy properties
  @StateObject private var stateManager = BottomSheetStateManager()
  
  // User interaction fields
  @State private var selectedPage: Int = 0
  @State private var title: String = "Activate Card"
  @State private var logText: String = ""
  @State private var isLoading: Bool = false
  @State private var showSuccess: Bool = false
  
  // User interaction fields
  @State private var showUserInputForm: Bool = false
  @State private var userRequirements: [DataRequirement] = []
  @State private var continueCallback: ((Dictionary<String, String>) -> Void)? = nil
  
  // App IDs and service IDs for Fidesmo cards - using the same ones from the example
  private let fidesmoAppId = "f374c57e"
  private let fidesmoServiceId = "install"
  
  // Card data service - inject necessary dependencies from RainFeature
  @Injected(\.rainCardRepository) private var rainCardRepository
  
  // Card data state
  @State private var activeCard: RainCardEntity?
  @State private var cardMetaData: CardMetaData?
  
  // Track the connection state
  @State private var currentConnection: NfcDevice?
  
  // Connection subject for device communication
  @State private var connectionSubject = BehaviorSubject<DeviceConnection?>(value: nil)
    
    // Add a state variable to track reconnection needed
    @State private var needsReconnection: Bool = false
  
  // API dispatcher for Fidesmo API requests
  private let apiDispatcher = FidesmoApiDispatcher(host: "https://api.fidesmo.com", localeStrings: "en")
  
  // Client info for Fidesmo API
  private let clientInfo = ClientInfo(clientType: .iphone, applicationName: "LiquidityFinancial")
  
  // Add error message state
  @State private var errorMessage: String? = nil
    
    // Add this property to track the current delivery step
    @State private var currentStep: Int = 0
    
    // Add a delivery type enum to track the current operation state
    @State private var deliveryType: DeliveryType = .notStarted
  
  // Initialize with just the bindings
  init(isPresented: Binding<Bool>, sheetHeight: Binding<CGFloat>) {
    self._isPresented = isPresented
    self._sheetHeight = sheetHeight
  }
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Button {
          self.isPresented = false
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
      // Initialize NFC manager and use cases through the state manager
      stateManager.initializeWith(listener: self, repository: rainCardRepository)
    }
  }
  
  private var activationView: some View {
    VStack(spacing: 24) {
      // Add error card if there's an error message
      if let errorMessage = errorMessage {
        VStack(alignment: .leading, spacing: 8) {
          Text("Activation Error")
            .font(Fonts.regular.swiftUIFont(size: 18))
            .foregroundColor(Colors.error.swiftUIColor)
          
          Text(errorMessage)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(10)
        .padding(.bottom, 12)
      }
      
      VStack(alignment: .leading, spacing: 12) {
        Text("Activate your Limited Edition Card")
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(Colors.label.swiftUIColor)
        
        Text("To activate your card, simply hold your iPhone near the NFC Fidesmo card after tapping the button below.")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
        
        VStack(alignment: .leading, spacing: 8) {
          Text("Tips for successful scanning:")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.8))
            .padding(.top, 8)
          
          HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text("Hold the top edge of your phone against the card")
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.7))
          
          HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text("Keep the phone steady throughout the entire process")
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.7))
          
          HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text("If the process completes even if it shows an error, your card is likely activated")
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.7))
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 24)
      
      Spacer()
      
      // Modify the button section to support reconnection
      VStack(spacing: 12) {
        if needsReconnection {
          FullSizeButton(title: "Scan Card to Continue", isDisable: false, type: .primary) {
            // Restart NFC session to continue the process
            needsReconnection = false
            stateManager.nfcManager?.startNfcDiscovery(message: "Hold your card to continue activation")
          }
          .padding(.horizontal, 24)
          
          Text("Your previous progress was saved. Continue where you left off.")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
        } else if case .transceive = deliveryType {
          FullSizeButton(title: "Scan Card to Continue", isDisable: false, type: .primary) {
            startDelivery()
          }
          .padding(.horizontal, 24)
        } else {
          FullSizeButton(title: "Start Activation", isDisable: false, type: .primary) {
            startDelivery()
          }
          
          FullSizeButton(title: "Cancel", isDisable: false, type: .secondary) {
              cancelDelivery()
          }
        }
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
      
      Text(deliveryType == .transceive ? "Ready to Continue" : "Processing...")
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
      
      // Show different buttons based on delivery type
      if deliveryType == .transceive {
        FullSizeButton(title: "Scan Card to Continue", isDisable: false, type: .primary) {
          stateManager.nfcManager?.startNfcDiscovery(message: "Hold your iPhone near the Fidesmo card again")
        }
        .padding(.horizontal, 24)
      }
        
        // Cancel button always available
        FullSizeButton(title: "Cancel Activation", isDisable: false, type: .secondary) {
            cancelDelivery()
        }
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
        self.isPresented = false
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .padding(.top, 24)
  }
  
  private func startDelivery() {
    // Reset error message when starting a new delivery
    errorMessage = nil
    isLoading = true
    logText = "Starting NFC session..."
    addToLog("App ID: \(fidesmoAppId), Service ID: \(fidesmoServiceId)")
    addToLog("API Host: https://api.fidesmo.com")
    
    // Fetch user's card information before starting NFC session
    fetchCardInformation()
    
    // Test basic connectivity to Fidesmo API
    let url = URL(string: "https://api.fidesmo.com")!
    let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
      if let error = error {
        addToLog("ERROR: Cannot reach Fidesmo API: \(error.localizedDescription)")
      } else if let httpResponse = response as? HTTPURLResponse {
        addToLog("Fidesmo API reachable with status: \(httpResponse.statusCode)")
      }
    }
    task.resume()
    
    // Check if NFC is available on this device
    if NFCNDEFReaderSession.readingAvailable {
      addToLog("NFC is available on this device")
    } else {
      addToLog("Warning: NFC is not available on this device")
    }
    
      stateManager.nfcManager?.startNfcDiscovery(message: "Hold your iPhone near an NFC Fidesmo tag")
  }
  
  private func fetchCardInformation() {
    Task { @MainActor [self] in
      do {
        // Safely unwrap use cases
        guard let getCardsUseCase = stateManager.getCardsUseCase else {
          addToLog("Error: Card use case not initialized")
          return
        }
        
        // Get the user's cards using our initialized use case
        let cards = try await getCardsUseCase.execute()
        addToLog("Fetched \(cards.count) cards from account")
        
        // Find the first active card
        if let firstActiveCard = cards.first(where: { $0.cardStatus == "ACTIVE" }) {
          // Fix the type casting issue for RainCardEntity
          activeCard = RainCardEntity(
            cardId: firstActiveCard.cardId,
            last4: firstActiveCard.last4,
            cardStatus: firstActiveCard.cardStatus,
            expMonth: firstActiveCard.expMonth,
            expYear: firstActiveCard.expYear
          )
          
          addToLog("Found active card ending in \(firstActiveCard.last4 ?? "unknown")")
          
          // Generate a proper session ID using the RainService
          let sessionId = stateManager.generateSessionId()
          addToLog("Generated secure session ID for card details")
            
          guard let cardID = firstActiveCard.cardId else {
            addToLog("Card ID not available for active card")
            return
          }
          
          guard let getSecretCardInformationUseCase = stateManager.getSecretCardInformationUseCase else {
            addToLog("Error: Secret card info use case not initialized")
            return
          }
          
          addToLog("Retrieving secure card information...")
          let secretInformation = try await getSecretCardInformationUseCase.execute(
            sessionID: sessionId,
            cardID: cardID
          )
          
            let pan = stateManager.decrypt(ivBase64: secretInformation.encryptedPanEntity.iv, dataBase64: secretInformation.encryptedPanEntity.data)
            let cvv = stateManager.decrypt(ivBase64: secretInformation.encryptedCVCEntity.iv, dataBase64: secretInformation.encryptedCVCEntity.data)
          
          // Store the card meta data
          cardMetaData = CardMetaData(pan: pan, cvv: cvv)
          addToLog("Successfully retrieved card information (last 4: \(pan.suffix(4)))")
        } else {
          addToLog("No active cards found")
        }
      } catch {
        addToLog("Error fetching card information: \(error.localizedDescription)")
      }
    }
  }
  
  private func addToLog(_ message: String) {
    print("Fidesmo log: \(message)")
    
    DispatchQueue.main.async { [self] in
      logText += "\n\(message)"
    }
  }
  
  // Using the iOS-specific pattern from CompleteDeliveryView
  private func getDeviceDescription(device: DeviceConnection) -> Single<DeviceDescription> {
    return device.getDescription(dispatcher: apiDispatcher).asSingle()
  }
  
  private func getServiceDescription(cin: CIN, appId: String, serviceId: String) -> Single<ServiceDescriptionResponse> {
    let serviceDescTask = JsonRequestTask<ServiceDescriptionResponse>(dispatcher: apiDispatcher)
    let request = AppStoreRequests.serviceDescription(appId: appId, serviceId: serviceId, cin: cin, clientInfo: clientInfo)
    return serviceDescTask.perform(request).asSingle()
  }
  
  // Combine Device and Service Description fetching
  private func getDeviceAndServiceDescription(device: DeviceConnection, appId: String, serviceId: String) -> Single<(DeviceDescription, ServiceDescriptionResponse)> {
    return getDeviceDescription(device: device)
      .flatMap { deviceDescription -> Single<(DeviceDescription, ServiceDescriptionResponse)> in
        self.addToLog("Device description fetched: \(deviceDescription.name)")
        self.addToLog("Device CIN: \(deviceDescription.cin)")
        
        return self.getServiceDescription(cin: deviceDescription.cin, appId: appId, serviceId: serviceId)
          .map { serviceDescription -> (DeviceDescription, ServiceDescriptionResponse) in
            self.addToLog("Service description fetched successfully")
            return (deviceDescription, serviceDescription)
          }
      }
  }
  
  private func startDeliveryProcess(device: NfcDevice) {
    // Begin delivery process
    addToLog("Starting delivery with device: \(device.deviceId)")
    
    // Set up the connection on the subject
    connectionSubject.onNext(device)
    
    // Get both device and service descriptions
    getDeviceAndServiceDescription(device: device, appId: fidesmoAppId, serviceId: fidesmoServiceId)
      .subscribe(
        onSuccess: { [self] (deviceDescription, serviceDescription) in
          // Extract the public key from the service description
          if let publicKey = serviceDescription.description.certificate {
            addToLog("Obtained public key for secure encryption")
            self.stateManager.servicePublicKey = publicKey
          } else {
            addToLog("Warning: No public key found in service description!")
          }
          
          // Important: Invalidate the NFC session since we don't need it right now
          stateManager.nfcManager?.invalidateSession()
          addToLog("Closing initial NFC session after getting device info")
          
          // Now proceed with delivery using the descriptions
          proceedWithDelivery(device: device, deviceDescription: deviceDescription, serviceDescription: serviceDescription.description)
        },
        onFailure: { [self] error in
          addToLog("Error fetching descriptions: \(error.localizedDescription)")
          
          if let networkError = error as? NetworkError {
            addToLog("Network Error Details: \(networkError)")
          }
          
          // Store the error message and show activation view again
          DispatchQueue.main.async {
            self.errorMessage = "Failed to connect to card service: \(error.localizedDescription)"
            self.isLoading = false
          }
          
          // Invalidate the NFC session on error
          stateManager.nfcManager?.invalidateSession(error: "Failed to get device information")
        }
      )
      .disposed(by: stateManager.disposeBag)
  }
  
  private func proceedWithDelivery(device: NfcDevice, deviceDescription: DeviceDescription, serviceDescription: ServiceDescription) {
    // Create delivery manager with connection subject
    let deliveryManager = DeliveryManager(connection: connectionSubject, dispatcher: apiDispatcher)
    
    addToLog("Delivering to device with CIN: \(deviceDescription.cin)")
    
    // Get the public key from the service description
    let publicKey = serviceDescription.certificate ?? ""
    
    if !publicKey.isEmpty {
      addToLog("Using public key from service description for encryption")
    } else {
      addToLog("Warning: No public key available for encryption!")
    }
    
    // Store the public key in the state manager
    stateManager.servicePublicKey = publicKey
    
    // IMPORTANT: DON'T invalidate the NFC session here
    // We keep the session active for continuous operation
    
    // Deliver with the public key
    deliverWithPublicKey(
      device: device,
      deviceDescription: deviceDescription,
      publicKey: publicKey,
      deliveryManager: deliveryManager,
      clientInfo: clientInfo
    )
  }
  
  private func deliverWithPublicKey(device: NfcDevice, deviceDescription: DeviceDescription, publicKey: String, deliveryManager: DeliveryManager, clientInfo: ClientInfo) {
    addToLog("Using Fidesmo public key for encryption: \(publicKey.isEmpty ? "Not Available" : "Available")")
    
    // Important: Don't start with .none delivery type - wait for server/device operations
    deliveryType = .notStarted
    
    deliveryManager.deliver(
      appId: fidesmoAppId,
      serviceId: fidesmoServiceId,
      cin: deviceDescription.cin,
      initialUserData: [:],
      publicKey: publicKey,
      clientInfo: clientInfo
    )
    .retry(3)
    .observe(on: MainScheduler.instance)
    .subscribe(onNext: { [self] progress in
      switch progress {
      case .notStarted:
        addToLog("Starting card setup...")
        
      case .operationInProgress(let description, let dataFlow):
        if let descriptionStep = description?.currentStep, descriptionStep != currentStep {
          addToLog("Moving to step \(descriptionStep) of \(description?.totalSteps ?? 0)")
          currentStep = descriptionStep
        }
        
        if case .toDevice(let commands) = dataFlow {
          addToLog("📱 COMMANDS TO SEND: \(commands)")
          
          // Set delivery type to transceive but DON'T automatically start NFC discovery
          // This lets the user manually initiate the scan with the button
          deliveryType = .transceive
          
          // Note: we're not automatically starting NFC discovery here
          // The user will press the "Scan Card to Continue" button which will start it
        } else if case .talkingToServer(let responses) = dataFlow {
          deliveryType = .none
          addToLog("Server communication: \(responses)")
          
          // Add a small delay between server operations to avoid overwhelming the server
          if stateManager.nfcManager?.isSessionActive() == true {
            // Keep session alive but give the server a moment to process
            stateManager.nfcManager?.changeAlertMessage(message: "Processing with server...")
          }
        }
        
      case .finished(let result):
        addToLog("Card activation completed!")
        stateManager.nfcManager?.changeAlertMessage(message: "Card activation completed!")
        
        if !result.success {
          let errorMsg = result.message.getFormattedText()
          // Log more details about the error
          addToLog("Activation Error: \(errorMsg)")
          addToLog("Error details: \(String(describing: result))")
          
          // Check if the error is about service availability
          if errorMsg.contains("temporarily unavailable") {
            // This may be a timing issue - add a small delay to server operations
            addToLog("Server appears to be temporarily unavailable - this may be a timing issue")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
              self.errorMessage = "Server temporarily unavailable. Please try again in a moment."
              isLoading = false
            }
          } else {
            DispatchQueue.main.async { [self] in
              self.errorMessage = "Activation failed: \(errorMsg)"
              isLoading = false
            }
          }
        } else {
          addToLog("Activation successfully completed with result: \(String(describing: result))")
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            isLoading = false
            showSuccess = true
          }
        }
        
      // Handle user interaction automatically with existing email
      case let .needsUserInteraction(reqs, callback):
        addToLog("User interaction required: \(reqs)")
        
        // Add handling for retry requirement
        if let retryRequirement = reqs.first(where: { $0.id == "retry" }) {
          addToLog("NFC connection retry needed - Ready to scan again")
          deliveryType = .transceive
          needsReconnection = true
          
          // Let the user press the "Scan Card to Continue" button
          callback([:]) // Empty response for retry requirement
        }
        else if let emailRequirement = reqs.first(where: { req in
          if case .edit(let format) = req.type, format == .email {
            return true
          }
          return false
        }) {
          // Auto-respond with email code (unchanged)
          let userEmail = viewModel.email
          addToLog("Auto-responding with email: \(userEmail)")
          
          var userData: [String: String] = [:]
          userData[emailRequirement.id] = userEmail
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: DispatchWorkItem(block: {
            callback(userData)
            addToLog("Automatically responded with user email")
          }))
        }
        // Check for card requirement
        else if let paymentCardRequirement = reqs.first(where: { req in
          if case .paymentcard = req.type {
            return true
          }
          return false
        }),
        let activeCard = activeCard,
        let cardData = cardMetaData {
          addToLog("Payment card requirement detected")

          // Attempt to auto-fill payment card data from our secure API
          addToLog("Payment card requirement detected - responding with user's card data")
          stateManager.nfcManager?.changeAlertMessage(message: "Adding payment details...")
          
          // Format the expiry month and year as 2-digit strings with leading zeros
          let expMonth = activeCard.expMonth ?? "00"
          let expYear = activeCard.expYear ?? "00"
          let formattedExpMonth = expMonth.count == 1 ? "0\(expMonth)" : expMonth
          let formattedExpYear = expYear.count > 2 ? String(expYear.suffix(2)) : expYear
          
          // Create payment card data in JSON format
          var cardDetails: [String: String] = [
            "cardNumber": cardData.pan,
            "expiryMonth": formattedExpMonth,
            "expiryYear": formattedExpYear,
            "cvv": cardData.cvv
          ]
          
          if stateManager.servicePublicKey.isEmpty {
            addToLog("ERROR: No public key for encryption!")
            stateManager.nfcManager?.invalidateSession(error: "Missing encryption key")
            isLoading = false
            return
          }
          
          addToLog("Using Fidesmo's encryption for card data")
            
            var cardDetailsString: String? {
                guard let data = try? JSONSerialization.data(withJSONObject: cardDetails,
                                                                    options: [.prettyPrinted]) else {
                    return nil
                }

                return String(data: data, encoding: .ascii)
            }
          
          var responseData: [String: String] = [:]
          if cardDetailsString != nil {
            addToLog("Card details JSON created successfully")
            responseData[paymentCardRequirement.id] = cardDetailsString
            
            // Call callback directly - no delay needed
            callback(responseData)
            stateManager.nfcManager?.changeAlertMessage(message: "Processing your card...")
            addToLog("Sent payment card data with proper encryption")
          } else {
            addToLog("ERROR: Failed to create card details JSON")
            stateManager.nfcManager?.invalidateSession(error: "Failed to process card data")
            isLoading = false
          }
        }
        else if let acceptRequirement = reqs.first(where: { req in
          if case .option(let format) = req.type, format == .button, req.id == "accept", req.labels?.count == 1 {
            return true
          }
          return false
        }) {
          // Respond to accept requirement immediately
          addToLog("Auto-responding with accept")
          callback([acceptRequirement.id: "0"])
          addToLog("Automatically responded with accept")
        } else {
          addToLog("Unknown requirement type - skipping")
          callback([:])
          addToLog("Skipped unknown requirement")
        }
        
      default:
        break
      }
    }, onError: { [self] error in
      addToLog("Error in delivery: \(error.localizedDescription)")
      
      if let apduError = error as? ApduTransceiveError {
        addToLog("APDU Error: \(apduError)")
      }
      
      // Store the error message
      DispatchQueue.main.async {
        self.errorMessage = "Activation error: \(error.localizedDescription)"
      }
      
      // Ensure NFC session is closed on error
//      stateManager.nfcManager?.invalidateSession(error: "An error occurred")
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: { [self] in
        isLoading = false
      }))
    }, onCompleted: { [self] in
      addToLog("Process completed")
      // Ensure NFC session is closed when process completes
      stateManager.nfcManager?.invalidateSession()
    })
    .disposed(by: stateManager.disposeBag)
  }
  
  // Add this new function to handle cancellation
  private func cancelDelivery() {
    // Log the cancellation
    addToLog("Activation cancelled by user")
    
    // Close any active NFC session
    stateManager.nfcManager?.invalidateSession(error: "Activation cancelled")
    currentConnection?.invalidateSession()
    
    // Reset the view state
    isLoading = false
    errorMessage = nil
    logText = ""
    
    // Optional: Add a slight delay before dismissing to ensure logging completes
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.isPresented = false
    }
  }
}

// MARK: - NFC Connection Delegate
extension BottomSheetView: NfcConnectionDelegate {
  func onDeviceConnected(device: NfcDevice) {
    addToLog("📲 DEVICE CONNECTED: \(device.deviceId)")
    addToLog("Current delivery type: \(deliveryType)")
    
    // Store the connection and immediately update subject
    currentConnection = device
    
    // Update prompt to keep user informed
    stateManager.nfcManager?.changeAlertMessage(message: "Keep card in position...")
    
    // Based on delivery type, take appropriate action
    switch deliveryType {
    case .notStarted:
      addToLog("🔍 INITIAL CONNECTION - Getting device info")
      startDeliveryProcess(device: device)
    case .transceive:
      addToLog("📡 TRANSCEIVE CONNECTION - Continuing with commands")
      connectionSubject.onNext(device)
      // Already updated connection above
    default:
      addToLog("⚠️ Connection during \(deliveryType) state")
    }
  }
  
  func onDeviceDisconnected(device: NfcDevice) {
    // Log device disconnection but continue with activation
    addToLog("Card disconnected - continuing with activation")
    
    // If the current connection is the one that disconnected, notify the subject
    if currentConnection?.deviceId == device.deviceId {
      addToLog("Main card disconnected - maintaining connection in process")
      
      // When we're in the middle of transceive and the session is invalidated
      if case .transceive = deliveryType {
        addToLog("Session invalidated during active transceive - preparing for reconnection")
        
        // Don't reset the process, but set up for reconnection
        deliveryType = .transceive
        
        // Show the scan button again to let user reinitiate the connection
        needsReconnection = true
        
        // Update UI to inform user to rescan
        stateManager.nfcManager?.changeAlertMessage(message: "Card connection lost. Please scan again to continue.")
      }
    }
  }
  
  func onWrongTagDetected() {
    addToLog("Wrong card type detected")
    stateManager.nfcManager?.invalidateSession(error: "This is not a Fidesmo card")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: { [self] in
      isLoading = false
    }))
  }
  
  func onSessionStarted() {
    addToLog("NFC session started")
  }
  
  func onSessionInvalidated(error: Error?) {
    if let error = error {
      addToLog("NFC session ended with error: \(error.localizedDescription)")
    } else {
      addToLog("NFC session ended normally")
    }
  }
  
  // Add this method to simplify initial data retrieval
  private func getInitialDeliveryData(connection: DeviceConnection) {
    addToLog("Getting initial delivery data for device")
    connectionSubject.onNext(connection)
    
    // Get both device and service descriptions - rest of logic remains the same
    getDeviceAndServiceDescription(device: connection, appId: fidesmoAppId, serviceId: fidesmoServiceId)
      .subscribe(
        onSuccess: { [self] (deviceDescription, serviceDescription) in
          // Extract the public key from the service description
          if let publicKey = serviceDescription.description.certificate {
            addToLog("Obtained public key for secure encryption")
            self.stateManager.servicePublicKey = publicKey
          } else {
            addToLog("Warning: No public key found in service description!")
          }
          
          // Important: Invalidate the NFC session since we don't need it right now
          stateManager.nfcManager?.invalidateSession()
          addToLog("Closing initial NFC session after getting device info")
          
          // Now proceed with delivery using the descriptions
          proceedWithDelivery(device: connection as! NfcDevice, deviceDescription: deviceDescription, serviceDescription: serviceDescription.description)
        },
        onFailure: { [self] error in
          addToLog("Error fetching descriptions: \(error.localizedDescription)")
          
          if let networkError = error as? NetworkError {
            addToLog("Network Error Details: \(networkError)")
          }
          
          // Store the error message and show activation view again
          DispatchQueue.main.async {
            self.errorMessage = "Failed to connect to card service: \(error.localizedDescription)"
            self.isLoading = false
          }
          
          // Invalidate the NFC session on error
          stateManager.nfcManager?.invalidateSession(error: "Failed to get device information")
        }
      )
      .disposed(by: stateManager.disposeBag)
  }
}

// State manager class to handle non-value-semantics properties
final class BottomSheetStateManager: ObservableObject {
  var nfcManager: NfcManager?
  var getCardsUseCase: RainDomain.RainGetCardsUseCaseProtocol?
  var getSecretCardInformationUseCase: RainDomain.RainSecretCardInformationUseCaseProtocol?
  
  // Add RainService dependency
  @Injected(\.rainService) private var rainService
  
  // Service information
  @Published var servicePublicKey: String = ""
  
  let disposeBag = DisposeBag()
  
  func initializeWith(listener: NfcConnectionDelegate, repository: Any) {
    self.nfcManager = NfcManager(listener: listener)
    
    // Cast the repository to the specific protocol type
    if let typedRepository = repository as? RainDomain.RainCardRepositoryProtocol {
      self.getCardsUseCase = RainDomain.RainGetCardsUseCase(repository: typedRepository)
      self.getSecretCardInformationUseCase = RainDomain.RainSecretCardInformationUseCase(repository: typedRepository)
    } else {
      print("Error: Repository is not of the expected type RainCardRepositoryProtocol")
    }
  }
  
  // Add function to generate session ID using RainService
  func generateSessionId() -> String {
    return rainService.generateSessionId()
  }
    
    func decrypt(ivBase64: String, dataBase64: String) -> String {
        return rainService.decryptData(ivBase64: ivBase64, dataBase64: dataBase64)
    }
  
  // Helper method to allow the NFC manager to track if a session is active
  func isSessionActive() -> Bool {
    return nfcManager?.isSessionActive() ?? false
  }
}

// Add an extension to NfcManager to check if a session is active
extension NfcManager {
  // Use associated object pattern instead of stored property
  private static var sessionActiveKey: UInt8 = 0
  
  func isSessionActive() -> Bool {
    return (objc_getAssociatedObject(self, &NfcManager.sessionActiveKey) as? Bool) ?? false
  }
  
  // Update methods to track session state
  func markSessionAsActive() {
    objc_setAssociatedObject(self, &NfcManager.sessionActiveKey, true, .OBJC_ASSOCIATION_RETAIN)
  }
  
  func markSessionAsInactive() {
    objc_setAssociatedObject(self, &NfcManager.sessionActiveKey, false, .OBJC_ASSOCIATION_RETAIN)
  }
}

// Add DeliveryType enum to track the current state
enum DeliveryType {
  case notStarted
  case none  // Used during server communication
  case transceive  // Used when device communication is needed
}

// Add to DeliveryType enum for debugging
extension DeliveryType: CustomStringConvertible {
  var description: String {
    switch self {
    case .notStarted: return "NOT_STARTED"
    case .none: return "SERVER_COMMUNICATION"
    case .transceive: return "DEVICE_TRANSCEIVE"
    }
  }
}
