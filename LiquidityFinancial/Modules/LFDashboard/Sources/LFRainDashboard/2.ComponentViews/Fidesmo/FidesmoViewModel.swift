import Foundation
import Factory
import LFUtilities
import AuthorizationManager
import Services
import DevicesDomain
import Combine
import GeneralFeature
import LFFeatureFlags
import FidesmoCore
import RxSwift
import FidesmoCore
import CoreNfcBridge
import CoreNFC
import RainDomain

@MainActor
final class FidesmoViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  @LazyInjected(\.rainService) var rainService
  
  private let disposeBag = DisposeBag()
  
  private let apiDispatcher = FidesmoApiDispatcher(host: "https://api.fidesmo.com", localeStrings: "en")
  private let clientInfo = ClientInfo(clientType: .iphone, applicationName: "LiquidityFinancial")
  
  @Published var appId: String = "f374c57e"
  @Published var serviceId: String = "install"
  
  @Published var userResponseHandler: UserResponseHandler?
  @Published var userActionHandler: UserActionHandler?
  @Published var userDataResponse = UserDataResponse()
  @Published var onCancelDelivery: (() -> ())?
  
  var nfcManager: NfcManager?
  var currentConnection: NfcDevice?
  var connectionSubject = BehaviorSubject<DeviceConnection?>(value: nil)
  
  @Published var deliveryType: DeliveryType = .notStarted
  @Published var dataRequirements: [DataRequirement] = []
  @Published var dataRequirementUUID: UUID = UUID()
  @Published var deliveryProgress: DeliveryProgress = .notStarted
  @Published var deliveryRequestDescription: DeliveryRequestDescription?
  @Published var currentStep: Int = 0
  @Published var showLogger: Bool = false
  @Published var logText: String = ""
  
  let terms: String = "Fidesmo Terms and Conditions"
  
  private var cardData: (card: RainCardEntity, metadata: CardMetaData)?
  
  lazy var getCardsUseCase: RainGetCardsUseCaseProtocol = {
    RainGetCardsUseCase(repository: rainCardRepository)
  }()
  
  lazy var getSecretCardInformationUseCase: RainSecretCardInformationUseCaseProtocol = {
    RainSecretCardInformationUseCase(repository: rainCardRepository)
  }()
  
  var email: String {
    accountDataManager.userInfomationData.email ?? ""
  }
  
  func onAppear() {
    nfcManager = NfcManager(listener: self)
    fetchCardInformation()
  }
  
  func getURL(tappedString: String) -> URL? {
    let urlMapping: [String: String] = [
      terms: "https://fidesmo.com/privacy-policy/"
    ]
    
    return urlMapping[tappedString].flatMap { URL(string: $0) }
  }
}

extension FidesmoViewModel {
  func startDelivery(
    connection: Observable<DeviceConnection?>,
    deliveryRequestDescription: DeliveryRequestDescription
  ) {
    deliverService(
      device: connection,
      description: deliveryRequestDescription
    )
    .observe(on: MainScheduler.instance)
    .subscribe(
      onNext: { [weak self] progress in
        guard let self else { return }
        
        DispatchQueue.main.async {
          self.deliveryProgress = progress
          self.handleDeliveryProgress(progress)
        }
      },
      onError: { [weak self] error in
        guard let self else { return }
        
        DispatchQueue.main.async {
          self.restartDelivery()
          self.handleDeliveryError(error)
        }
      },
      onCompleted: { [weak self] in
        guard let self else { return }
        
        DispatchQueue.main.async {
          self.restartDelivery()
          self.addToLog("Subscription ended!")
        }
      }
    )
    .disposed(
      by: disposeBag
    )
  }
  
  private func getResponseFor(
    requirements: [DataRequirement]
  ) -> [String: String]? {
    var userResponse: [String: String] = [:]
    
    if let emailRequirement = requirements
      .first(
        where: { requirement in
          if case .edit(let format) = requirement.type,
             format == .email {
            
            return true
          }
          
          return false
        }
      ) {
      
      let userEmail = accountDataManager.userInfomationData.email ?? ""
      addToLog("Auto-responding with email: \(userEmail)")
      
      userResponse[emailRequirement.id] = userEmail
    }
    
    if let cardData,
       let paymentCardRequirement = requirements
      .first(
        where: { requirement in
          if case .paymentcard = requirement.type {
            return true
          }
          
          return false
        }
      ) {
      addToLog("Payment card requirement detected")
      // Format the expiry month and year as 2-digit strings with leading zeros
      let expMonth =  cardData.card.expMonth ?? "00"
      let expYear = cardData.card.expYear ?? "00"
      let formattedExpMonth = expMonth.count == 1 ? "0\(expMonth)" : expMonth
      let formattedExpYear = expYear.count > 2 ? String(expYear.suffix(2)) : expYear
      
      // Create payment card data in JSON format
      let cardDetails: [String: String] = [
        "cardNumber": cardData.metadata.pan,
        "expiryMonth": formattedExpMonth,
        "expiryYear": formattedExpYear,
        "cvv": cardData.metadata.cvv
      ]
      
      addToLog("Using Fidesmo's encryption for card data")
      
      var cardDetailsString: String? {
        guard let data = try? JSONSerialization.data(
          withJSONObject: cardDetails,
          options: [.prettyPrinted])
        else {
          return nil
        }
        
        return String(data: data, encoding: .ascii)
      }
      
      if cardDetailsString != nil {
        addToLog("Card details JSON created successfully")
        userResponse[paymentCardRequirement.id] = cardDetailsString
        addToLog("Auto-responding with card: \(String(describing: cardDetailsString))")
      }
    }
    
    if let acceptRequirement = requirements
      .first(
        where: { requirement in
          if case .option(let format) = requirement.type,
             format == .button,
             requirement.id == "accept",
             requirement.labels?.count == 1 {

            return true
          }
          return false
        }
      ) {
      
      addToLog("Auto-responding with accept")
      userResponse[acceptRequirement.id] = "0"
    }
    
    return userResponse.isEmpty ? nil : userResponse
  }
  
  private func getInitialDeliveryData(
    connection: DeviceConnection,
    appId: String,
    serviceId: String
  ) {
    connectionSubject = BehaviorSubject(value: nil)
    
    getDeviceAndServiceDescription(
      device: connection,
      appId: appId,
      serviceId: serviceId
    )
    .observe(on: MainScheduler.instance)
    .subscribe(
      onNext: { [weak self] deliveryRequestDescription in
        guard let self,
              let deliveryRequestDescription
        else {
          return
        }
        
        let setupRequirements = deliveryRequestDescription.serviceDesc.setupRequirements()
        // Handle the requirements automatically if possible. Otherwise, ask for user's input
        if let userResponse = getResponseFor(requirements: setupRequirements) {
          userDataResponse = userResponse
          startDelivery(connection: connectionSubject, deliveryRequestDescription: deliveryRequestDescription)
        } else {
          dataRequirements = setupRequirements
          
          userResponseHandler = { [weak self] userReponse in
            guard let self else { return }
            
            userDataResponse = userReponse
            startDelivery(connection: connectionSubject, deliveryRequestDescription: deliveryRequestDescription)
          }
        }
        
        DispatchQueue.main.async {
          self.deliveryType = .none // Disable button Interaction
          self.nfcManager?.invalidateSession()
        }
      },
      onError: { [weak self] error in
        guard let self else { return }
        
        addToLog("Error encountered while fetching device and service descriptions")
        handleDeliveryError(error)
      }
    )
    .disposed(
      by: disposeBag
    )
  }
  
  private func getDeviceDescription(
    device: DeviceConnection
  ) -> Observable<DeviceDescription> {
    device.getDescription(dispatcher: apiDispatcher)
  }
  
  private func getServiceDescription(
    cin: CIN,
    appId: String,
    serviceId: String
  ) -> Observable<ServiceDescriptionResponse> {
    let serviceDescTask = JsonRequestTask<ServiceDescriptionResponse>(dispatcher: apiDispatcher)
    let request = AppStoreRequests.serviceDescription(appId: appId, serviceId: serviceId, cin: cin, clientInfo: clientInfo)
    
    return serviceDescTask.perform(request)
  }
  
  private func getDeviceAndServiceDescription(
    device: DeviceConnection,
    appId: String,
    serviceId: String
  ) -> Observable<DeliveryRequestDescription?> {
    getDeviceDescription(device: device)
      .flatMap { [weak self] deviceDescription -> Observable<DeliveryRequestDescription?> in
        guard let self else { return Observable.just(nil) }
        addToLog("Got Device Description!")
        
        return getServiceDescription(
          cin: deviceDescription.cin,
          appId: appId,
          serviceId: serviceId
        )
        .map { [weak self] serviceDescription in
          guard let self else { return nil }
          addToLog("Got Service Description!")
          
          let deliveryRequestDescription = DeliveryRequestDescription(
            appId: appId,
            serviceId: serviceId,
            serviceDesc: serviceDescription.description,
            deviceDesc: deviceDescription
          )
          
          return deliveryRequestDescription
        }
      }
  }
  
  private func deliverService(
    device: Observable<DeviceConnection?>,
    description: DeliveryRequestDescription
  ) -> Observable<DeliveryProgress> {
    let deliveryManager = DeliveryManager(connection: device, dispatcher: apiDispatcher)
    
    onCancelDelivery = { [weak self] in
      guard let self else { return }
      // Cancelling delivery means sending a fatal error to the server, which will make the ongoing service delivery fail.
      // It can be used when the user navigates back, closes the application...
      // This lets the Fidesmo servers know that the delivery got interrupted by the user, and helps with QA and support, as otherwise the server would just see a timeout.
      deliveryManager.cancelDelivery(message: "Delivery cancelled by user")
      addToLog("The delivery was cancelled by the user.")
      
      restartDelivery()
    }
    
    // If the service delivery is Fidesmo Pay transaction history, add the timezone field to customize transaction timestamps to user's timezone
    if (description.serviceId == "tx-history" && (description.appId == "af1cc990" || description.appId == "f374c57e")) {
      userDataResponse["timezone"] = TimeZone.current.identifier
    }
    
    return deliveryManager
      .deliver(
        appId: description.appId,
        serviceId: description.serviceId,
        cin: description.deviceDesc.cin,
        initialUserData: userDataResponse,
        publicKey: description.serviceDesc.certificate,
        clientInfo: clientInfo
      )
  }
  
  private func handleDeliveryProgress(
    _ progress: DeliveryProgress
  ) {
    switch progress {
    case .notStarted:
      addToLog("Starting delivery!")
    case let .operationInProgress(description, dataFlow):
      if let descriptionStep = description?.currentStep {
        if descriptionStep != currentStep {
          if let currentConnection = currentConnection {
            currentConnection.invalidateSession()
          }
          nfcManager?.invalidateSession()
        }
        currentStep = descriptionStep
      }
      
      switch dataFlow {
      case .talkingToServer:
        addToLog("Talking to server!")
      case let .toDevice(commands):
        addToLog("_________________________________")
        addToLog("Commands sent to device: \(commands)")
      case let .toServer(responses):
        addToLog("_________________________________")
        addToLog("Response from the device : \(responses)")
      @unknown default:
        break
      }
      
    case let .needsUserInteraction(requirements, resultHandler):
      addToLog("Needs User Interaction: \(requirements.description)")
      nfcManager?.invalidateSession()
      //To be able to update the view when the requirements have not changed since the previous step
      //This applies mainly to requirements associated with the NFC connection retry
      if requirements == dataRequirements {
        dataRequirementUUID = UUID()
      }
      
      // Handle the requirements automatically if possible. Otherwise, ask for user's input
      if let userResponse = getResponseFor(requirements: requirements) {
        DispatchQueue.main.async {
          resultHandler(userResponse)
        }
      } else {
        DispatchQueue.main.async {
          self.dataRequirements = requirements
          self.userResponseHandler = resultHandler
        }
      }
    case let .needsUserAction(actions, actionHandler):
      addToLog("Needs User Action: \(actions.description)")
      userActionHandler = actionHandler
      handleUserActions(actions)
    case let .finished(status):
      let successStatus = status.success ? "Service delivery completed! :)" : "Service delivery failed! :("
      
      nfcManager?.changeAlertMessage(message: successStatus)
      nfcManager?.invalidateSession()
      addToLog(status.message.getFormattedText())
      
      restartDelivery()
      deliveryProgress = progress
    default:
      break
    }
  }
  
  private func handleUserActions(
    _ actions: [UiAction]
  ) {
    // The only user action used by Fidesmo Pay is phonecall at this moment
    // Ignore this for now
    
    //    if let phoneCallAction = actions.first(
    //      where: {
    //        $0.name == "phonecall"
    //      }
    //    ) {
    //      addToLog("Phonecall Action Received: \(phoneCallAction)")
    //
    //      if let number = phoneCallAction.parameters["number"],
    //         let numberUrl = URL(string: "tel://\(number)") {
    //        dataRequirements = [
    //          DataRequirement(
    //            label: phoneCallAction.description,
    //            labels: nil,
    //            id: "text",
    //            type: .text(.medium),
    //            appUrl: nil,
    //            appStoreId: nil,
    //            mandatory: false
    //          )
    //        ]
    //
    //        DispatchQueue.main.async {
    //          UIApplication.shared.open(numberUrl)
    //        }
    //      }
    //    }
  }
  
  private func handleDeliveryError(
    _ error: Error
  ) {
    switch error {
    case is NetworkError:
      manage(error: error as! NetworkError)
    case is DeviceError:
      manage(error: error as! DeviceError)
    default: break
    }
    nfcManager?.invalidateSession(error: error.localizedDescription)
    addToLog("Error: \(error)")
  }
}

extension FidesmoViewModel {
  private func fetchCardInformation(
  ) {
    Task {
      let cards = try await getCardsUseCase.execute()
      addToLog("Fetched \(cards.count) cards from account")
      
      // Find the first active card
      guard let firstActiveCard = cards.first(where: { $0.cardStatus == "ACTIVE" })
      else {
        addToLog("No active cards found")
        return
      }
      
      // Fix the type casting issue for RainCardEntity
      //let activeCard = mapToCardModel(card: firstActiveCard)
      let activeCard = RainCardEntity(
        cardId: firstActiveCard.cardId,
        last4: firstActiveCard.last4,
        cardStatus: firstActiveCard.cardStatus,
        expMonth: firstActiveCard.expMonth,
        expYear: firstActiveCard.expYear
      )
      
      addToLog("Found active card ending in \(firstActiveCard.last4 ?? "unknown")")
      
      // Generate a proper session ID using the RainService
      let sessionId = rainService.generateSessionId()
      addToLog("Generated secure session ID for card details")
      
      guard let cardID = firstActiveCard.cardId else {
        addToLog("Card ID not available for active card")
        return
      }
      
      addToLog("Retrieving secure card information...")
      let secretInformation = try await getSecretCardInformationUseCase.execute(
        sessionID: sessionId,
        cardID: cardID
      )
      
      let pan = rainService.decryptData(
        ivBase64: secretInformation.encryptedPanEntity.iv,
        dataBase64: secretInformation.encryptedPanEntity.data
      )
      
      let cvv = rainService.decryptData(
        ivBase64: secretInformation.encryptedCVCEntity.iv,
        dataBase64: secretInformation.encryptedCVCEntity.data
      )
      
      // Store the card meta data
      let cardMetaData = CardMetaData(
        pan: pan,
        cvv: cvv
      )
      
      addToLog("Successfully retrieved card information (last 4: \(pan.suffix(4)))")
      cardData = (activeCard, cardMetaData)
    }
  }
  
//  private func mapToCardModel(
//    card: RainCardEntity
//  ) -> CardModel {
//    CardModel(
//      id: card.cardId ?? card.rainCardId,
//      cardType: CardType(rawValue: card.cardType.lowercased()) ?? .virtual,
//      cardholderName: nil,
//      expiryMonth: Int(card.expMonth ?? .empty) ?? 0,
//      expiryYear: Int(card.expYear ?? .empty) ?? 0,
//      last4: card.last4 ?? .empty,
//      cardStatus: CardStatus(rawValue: card.cardStatus.lowercased()) ?? .unactivated
//    )
//  }
}

extension FidesmoViewModel: NfcConnectionDelegate {
  func onDeviceConnected(device: NfcDevice) {
    currentConnection = device
    nfcManager?.changeAlertMessage(message: "Device connected")
    
    switch deliveryType {
    case .notStarted:
      getInitialDeliveryData(connection: device, appId: appId, serviceId: serviceId)
    case .transceive:
      connectionSubject.onNext(device)
    default: return
    }
    
    addToLog("Device connected")
  }
  
  func onDeviceDisconnected(device: NfcDevice) {
    addToLog("Device disconnected")
  }
  
  func onWrongTagDetected() {
    addToLog("Wrong tag detected")
  }
  
  func onSessionStarted() {
    addToLog("Session started")
  }
  
  func onSessionInvalidated(error: Error?) {
    addToLog("Session invalidated")
    if let error = error {
      addToLog("Session invalidated: " + error.localizedDescription)
    }
  }
}

extension FidesmoViewModel {
  func proceedFromOpenUrlRequirement(
    requirements: [DataRequirement],
    handler: UserResponseHandler
  ) {
    if let firstRequirement = requirements.first, firstRequirement.type == .openUrl {
      handler([firstRequirement.id : ""])
    }
  }
  
  private func authenticationRequirement(
    requirements: [DataRequirement],
    handler: UserResponseHandler
  ) {
    if let firstRequirement = requirements.first, case .openUrl = firstRequirement.type {
      handler([firstRequirement.id : ""])
    }
  }
  
  private func restartDelivery() {
    deliveryType = .notStarted
    deliveryProgress = .notStarted
    currentStep = 0
    currentConnection = nil
    userResponseHandler = nil
    userActionHandler = nil
    onCancelDelivery = nil
    dataRequirements.removeAll()
  }
  
  private func manage(
    error: NetworkError
  ) {
    switch error {
    case let .badInput(reason: errorReason):
      addToLog(errorReason)
    case let .badResponse(code, error, message):
      if let code = code {
        addToLog("Code error: \(code)")
        switch code {
        case 403:
          addToLog("The delivery is not allowed due to restrictions of the service.")
        case 404:
          addToLog("The service could not be found.")
        case 406:
          addToLog("The application does not support this service delivery.")
        case 412:
          addToLog("The state of the device is not compatible with this service delivery.")
        case 409:
          addToLog("Input error, the device might not be registered in the system.")
        case 500:
          addToLog("Internal server error.")
        case 502:
          addToLog("An external sevice was misconfigured or responded with an error.")
        case 503:
          addToLog("External service is not available.")
        case 504:
          addToLog("The service provider didn't answer in a timely manner.")
        default:
          addToLog("Unknown error code received.")
        }
      }
      if let error = error {
        addToLog(error.localizedDescription)
      }
      if let message = message {
        addToLog("Answer from server: \(message)")
      }
    case let .jsonError(jsonError):
      addToLog(jsonError?.localizedDescription ?? "Unknown json error")
    case .noData:
      addToLog("NetworkError: Invalid data")
    case .unknown:
      addToLog("Unknown error")
    @unknown default:
      break
    }
  }
  
  private func manage(
    error: DeviceError
  ) {
    switch error {
    case let .readingError(reason: errorReason), let .noDeviceCin(reason: errorReason), let .eligibilityError(reason: errorReason):
      addToLog("DeviceError: \(errorReason)")
    @unknown default:
      break
    }
  }
  
  func addToLog(
    _ message: String
  ) {
    print("log: ", message)
    //logText += "\n\(message)"
  }
}

enum DeliveryType {
  case none, notStarted, getInstalledApps, getInstalledAppsPv2, getDeviceData, confirmAccess, sendPan, acceptTermsAndConditions, transceive
}

typealias DeliveryRequestDescription = (appId: AppId, serviceId: ServiceId, serviceDesc: ServiceDescription, deviceDesc: DeviceDescription)

// MARK: - Types
extension FidesmoViewModel {
  enum OpenSafariType: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case terms
  }
}
