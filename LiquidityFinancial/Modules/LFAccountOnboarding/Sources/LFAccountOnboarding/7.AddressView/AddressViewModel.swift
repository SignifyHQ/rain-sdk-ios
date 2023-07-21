import Combine
import SmartyStreets
import PhoneNumberKit
import SwiftUI
import LFUtilities
import Factory
import OnboardingData
import NetSpendData

// swiftlint:disable all
@MainActor
final class AddressViewModel: ObservableObject {
  enum Navigation {
    case question(QuestionsEntity)
    case document
    case pendingIDV
    case declined
    case inReview
    case home
  }
  
  @Injected(\.userDataManager) var userDataManager
  @Injected(\.netspendRepository) var netspendRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var displaySuggestions: Bool = false
  @Published var navigation: Navigation?
  @Published var addressList: [AddressData] = []
  @Published var isActionAllowed: Bool = false {
    didSet {
      guard isActionAllowed else { return }
      userDataManager.update(addressLine1: addressLine1)
      userDataManager.update(addressLine2: addressLine2)
      userDataManager.update(city: city)
      userDataManager.update(state: state)
      userDataManager.update(postalCode: zipCode)
      userDataManager.update(country: "US")
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
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        var governmentID: String = ""
        var type: String = ""
        if let ssn = userDataManager.userInfomationData.ssn {
          type = "ssn"
          governmentID = ssn
        } else if let passport = userDataManager.userInfomationData.passport {
          type = "passport"
          governmentID = passport
        }
        let agreementIDS = netspendDataManager.agreement?.agreements.compactMap { $0.id } ?? []
        let encryptedData = try netspendDataManager.sdkSession?.encryptWithJWKSet(value: [
          "date_of_birth": userDataManager.userInfomationData.dateOfBirth ?? "",
          "government_id": [
            "type": type,
            "value": governmentID
          ]
        ])
        let param = AccountPersonParameters(
          firstName: userDataManager.userInfomationData.firstName ?? "",
          lastName: userDataManager.userInfomationData.lastName ?? "",
          middleName: userDataManager.userInfomationData.fullName ?? "",
          agreementIDS: agreementIDS,
          phone: userDataManager.userInfomationData.phone ?? "",
          email: userDataManager.userInfomationData.email ?? "",
          fullName: userDataManager.userInfomationData.fullName ?? "",
          dateOfBirth: userDataManager.userInfomationData.dateOfBirth ?? "",
          addressLine1: userDataManager.userInfomationData.addressLine1 ?? "",
          addressLine2: userDataManager.userInfomationData.addressLine2 ?? "",
          city: userDataManager.userInfomationData.city ?? "",
          state: userDataManager.userInfomationData.state ?? "",
          country: userDataManager.userInfomationData.country ?? "",
          postalCode: userDataManager.userInfomationData.postalCode ?? "",
          encryptedData: encryptedData ?? ""
        )
        let person = try await netspendRepository.createAccountPerson(personInfo: param, sessionId: netspendDataManager.serverSession?.id ?? "")
        netspendDataManager.update(accountPersonData: person)
        
        let workflows = try await self.netspendRepository.getWorkflows()
        
        if let steps = workflows.steps.first {
          for stepIndex in 0...(steps.steps.count - 1) {
            let step = steps.steps[stepIndex]
            switch step.missingStep {
            case .identityQuestions:
              let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: userDataManager.sessionID)
              if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
                let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
                navigation = .question(questionsEntity)
              }
            case .provideDocuments:
              let documents = try await netspendRepository.getDocuments(sessionId: userDataManager.sessionID)
              netspendDataManager.update(documentData: documents)
              navigation = .document
            case .primaryPersonKYCApprove:
              navigation = .home
            case .KYCData:
              navigation = .pendingIDV
            case .acceptAgreement:
              break
            case .expectedUse:
              break
            case .identityScan:
              navigation = .pendingIDV
            }
          }
        }

      } catch {
        log.error(error)
        toastMessage = error.localizedDescription
      }
    }
  }

  private var isStateValid: Bool {
    if LFUtility.cryptoEnabled {
      return !Constants.supportedStates.contains(state.uppercased())
    } else {
      return true
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
