import Combine
import SmartyStreets
import PhoneNumberKit
import SwiftUI
import LFUtilities
import Factory
import OnboardingData
import AccountData
import NetSpendData
import LFServices
import LFLocalizable
import DevicesData

// swiftlint:disable all
@MainActor
final class AddressViewModel: ObservableObject {
  enum Navigation {
    case question(QuestionsEntity)
    case document
    case pendingIDV
    case declined
    case inReview
    case missingInfo
    case agreement
    case home
  }
  
  enum Popup {
    case waitlist(String)
    case waitlistJoined
  }
  
#if DEBUG
  var countGenerateUser: Int = 0
#endif
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  
  @Published var isLoading: Bool = false
  @Published var popup: Popup?
  @Published var toastMessage: String?
  @Published var displaySuggestions: Bool = false
  @Published var navigation: Navigation?
  @Published var addressList: [AddressData] = []
  @Published var isActionAllowed: Bool = false {
    didSet {
      guard isActionAllowed else { return }
      accountDataManager.update(addressLine1: addressLine1)
      accountDataManager.update(addressLine2: addressLine2)
      accountDataManager.update(city: city)
      accountDataManager.update(state: state)
      accountDataManager.update(postalCode: zipCode)
      accountDataManager.update(country: "US")
    }
  }
  
  @Published var addressLine1: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  @Published var addressLine2: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  @Published var city: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  @Published var state: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  @Published var zipCode: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  var userNameDisplay: String {
    get {
      UserDefaults.userNameDisplay
    }
    set {
      UserDefaults.userNameDisplay = newValue
    }
  }
  
  private var subscriptions = Set<AnyCancellable>()
  private var pauseAutocomplete = false
  private var isSuggesionTapped: Bool = false
  private var workflowData: APIWorkflowsData?
  
  init() {
    $addressLine1
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .dropFirst(2)
      .removeDuplicates()
      .sink { [weak self] value in
        guard let self = self else { return }
        guard !self.pauseAutocomplete else {
          self.pauseAutocomplete = false
          return
        }
        self.fetchAddress(query: value.capitalized)
      }
      .store(in: &subscriptions)
  }

  func stopSuggestions() {
    displaySuggestions = false
  }

  func select(suggestion: AddressData) {
    pauseAutocomplete = true
    addressLine1 = suggestion.addressline1
    city = suggestion.city
    state = suggestion.state
    zipCode = suggestion.zipcode
    displaySuggestions = false
  }

  func actionContinue() {
    guard isStateValid else {
      let message = LFLocalizable.waitlistMessage(accountDataManager.userInfomationData.firstName ?? "")
      popup = .waitlist(message)
      return
    }
    
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let param = try createAccountPersonParameters()
        let person = try await netspendRepository.createAccountPerson(personInfo: param, sessionId: accountDataManager.sessionID)
        netspendDataManager.update(accountPersonData: person)
        
        let userAttributes = IntercomService.UserAttributes(phone: accountDataManager.phoneNumber, email: param.email)
        intercomService.loginIdentifiedUser(userAttributes: userAttributes)
        
        try await apiFetchWorkflows()

      } catch {
        log.error(error)
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
  
  func magicFillAccount() {
#if DEBUG
    countGenerateUser += 1
    if countGenerateUser >= 3 {
      let userMock = UserMockManager.mockUser(countTap: countGenerateUser)
      addressLine1 = userMock.line1
      city = userMock.city
      state = userMock.state
      zipCode = userMock.zipCode
      if countGenerateUser >= 5 { countGenerateUser = 0 }
    }
#endif
  }
  
  private func createAccountPersonParameters() throws -> AccountPersonParameters {
    var governmentID: String = ""
    var typeGovernmentID: String = ""
    if let ssn = accountDataManager.userInfomationData.ssn {
      typeGovernmentID = IdNumberType.ssn.rawValue
      governmentID = ssn
    } else if let passport = accountDataManager.userInfomationData.passport {
      typeGovernmentID = IdNumberType.passport.rawValue
      governmentID = passport
    }
    let agreementIDS = netspendDataManager.agreement?.agreements.compactMap { $0.id } ?? []
    let encryptedData = try netspendDataManager.sdkSession?.encryptWithJWKSet(value: [
      "date_of_birth": accountDataManager.userInfomationData.dateOfBirth ?? "",
      "government_id": [
        "type": typeGovernmentID,
        "value": governmentID
      ]
    ])
    let param = AccountPersonParameters(
      firstName: accountDataManager.userInfomationData.firstName ?? "",
      lastName: accountDataManager.userInfomationData.lastName ?? "",
      middleName: accountDataManager.userInfomationData.fullName ?? "",
      agreementIDS: agreementIDS,
      phone: accountDataManager.userInfomationData.phone ?? "",
      email: accountDataManager.userInfomationData.email ?? "",
      fullName: accountDataManager.userInfomationData.fullName ?? "",
      dateOfBirth: accountDataManager.userInfomationData.dateOfBirth ?? "",
      addressLine1: accountDataManager.userInfomationData.addressLine1 ?? "",
      addressLine2: accountDataManager.userInfomationData.addressLine2 ?? "",
      city: accountDataManager.userInfomationData.city ?? "",
      state: accountDataManager.userInfomationData.state ?? "",
      country: accountDataManager.userInfomationData.country ?? "",
      postalCode: accountDataManager.userInfomationData.postalCode ?? "",
      encryptedData: encryptedData ?? "",
      idNumber: governmentID,
      idNumberType: typeGovernmentID
    )
    return param
  }
  
  func apiFetchWorkflows() async throws {
    let workflows = try await self.netspendRepository.getWorkflows()
    self.workflowData = workflows
    try await self.handleWorkflowData(data: workflows)
  }
  
  private func handleWorkflowData(data: APIWorkflowsData?) async throws {
    guard let workflowData = data else {
      return
    }
    if workflowData.steps.isEmpty {
      navigation = .inReview
      return
    }
    
    if let steps = workflowData.steps.first {
      for stepIndex in 0...(steps.steps.count - 1) {
        let step = steps.steps[stepIndex]
        switch step.missingStep {
        case .identityQuestions:
          let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
          if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
            let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
            navigation = .question(questionsEntity)
          }
        case .provideDocuments:
          let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
          netspendDataManager.update(documentData: documents)
          navigation = .document
        case .KYCData:
          navigation = .missingInfo
        case .primaryPersonKYCApprove:
          navigation = .inReview
        case .acceptAgreement:
          navigation = .agreement
        case .expectedUse:
          break
        case .identityScan:
          navigation = .missingInfo
        case .acceptFeatureAgreement:
          break
        }
      }
    }
  }
}

extension AddressViewModel {
  func actionJoinWaitList() {
    callUpdateAPIToJoinWaitlist()
  }
  
  func actionLogout() {
    logout()
  }
  
  private var isStateValid: Bool {
    if LFUtility.cryptoEnabled {
      return !Constants.supportedStates.contains(state.uppercased())
    } else {
      return true
    }
  }
  
  private func callUpdateAPIToJoinWaitlist() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        _ = try await accountRepository.addToWaitList(waitList: "CRYPTO_PRODUCT") //support crypto product only
        popup = .waitlistJoined
      } catch {
        log.error(error.localizedDescription)
        popup = nil
        toastMessage = error.localizedDescription
      }
    }
  }
  
  private func logout() {
    Task {
      defer {
        isLoading = false
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        intercomService.pushEventLogout()
        popup = nil
        pushNotificationService.signOut()
      }
      isLoading = true
      do {
        async let deregisterEntity = devicesRepository.deregister(deviceId: LFUtility.deviceId, token: UserDefaults.lastestFCMToken)
        async let logoutEntity = accountRepository.logout()
        let deregister = try await deregisterEntity
        let logout = try await logoutEntity
        log.debug(deregister)
        log.debug(logout)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}

private extension AddressViewModel {
  func isAllDataFilled() {
    isActionAllowed = (!addressLine1.trimWhitespacesAndNewlines().isEmpty) &&
    (!city.trimWhitespacesAndNewlines().isEmpty) &&
    (!state.trimWhitespacesAndNewlines().isEmpty) &&
    (!zipCode.trimWhitespacesAndNewlines().isEmpty)
  }
}

extension AddressViewModel {
  func fetchAddress(query: String) {
    guard query.count > 2 else {
      displaySuggestions = false
      return
    }
    let id = Constants.smartyStreetsId
    let hostname = Constants.smartyStreetsHostName
    let client = ClientBuilder(id: id, hostname: hostname)
      .withLicenses(licenses: [Constants.smartyStreetsLicense])
      .buildUSAutocompleteProApiClient()

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      var lookup = USAutocompleteProLookup().withSearch(search: query)
      var error: NSError?
      _ = client.sendLookup(lookup: &lookup, error: &error)

      let suggestions: [AddressData] = lookup.result?.suggestions?.map {
        AddressData(
          addressline1: $0.streetLine ?? "",
          city: $0.city ?? "",
          state: $0.state ?? "",
          zipcode: $0.zipcode ?? ""
        )
      } ?? []

      DispatchQueue.main.async {
        self?.addressList = suggestions
        self?.displaySuggestions = !suggestions.isEmpty
      }
    }
  }
}
