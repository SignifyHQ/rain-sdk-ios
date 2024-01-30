import Combine
import SmartyStreets
import PhoneNumberKit
import SwiftUI
import LFUtilities
import Factory
import AccountData
import Services
import LFLocalizable
import DevicesData
import SolidDomain
import SolidData
import RewardData
import AccountDomain
import DevicesDomain

// swiftlint:disable all
@MainActor
final class AddressViewModel: ObservableObject {

  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.solidOnboardingRepository) var solidOnboardingRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var displaySuggestions: Bool = false
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
  
  lazy var solidOnboardingUseCase: SolidOnboardingUseCase = {
    SolidOnboardingUseCase(repository: solidOnboardingRepository)
  }()
  lazy var solidCreatePersonUseCase: SolidCreatePersonUseCase = {
    SolidCreatePersonUseCase(repository: solidOnboardingRepository)
  }()
  
  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
   return DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  
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
        let parameters = createPersonParameters()
        let result = try await solidCreatePersonUseCase.execute(parameters: parameters)
        if result {
          try await solidOnboardingFlowCoordinator.handlerOnboardingStep()
          analyticsService.track(event: AnalyticsEvent(name: .addressCompleted))
        } else {
          toastMessage = "Something went wrong, please try again later!"
        }
      } catch {
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  private func createPersonParameters() -> APISolidPersonParameters {
    var typeGovernmentID: String = ""
    var governmentID: String = ""
    if let ssn = accountDataManager.userInfomationData.ssn, ssn.isEmpty == false {
      typeGovernmentID = SolidIDType.SSN.rawValue
      governmentID = ssn
    } else if let passport = accountDataManager.userInfomationData.passport, passport.isEmpty == false {
      typeGovernmentID = SolidIDType.PASSPORT.rawValue
      governmentID = passport
    }
    let solidAddress = SolidAddress(
      line1: accountDataManager.userInfomationData.addressLine1,
      line2: accountDataManager.userInfomationData.addressLine2,
      city: accountDataManager.userInfomationData.city,
      state: accountDataManager.userInfomationData.state,
      country: accountDataManager.userInfomationData.country,
      postalCode: accountDataManager.userInfomationData.postalCode
    )
    let solidCreatePersonRequest = SolidCreatePersonRequest(
      firstName: accountDataManager.userInfomationData.firstName,
      middleName: "",
      lastName: accountDataManager.userInfomationData.lastName,
      email: accountDataManager.userInfomationData.email,
      phone: accountDataManager.userInfomationData.phone,
      dateOfBirth: accountDataManager.userInfomationData.dateOfBirth,
      idNumber: governmentID,
      idType: typeGovernmentID,
      address: solidAddress)
    return APISolidPersonParameters(solidCreatePersonRequest: solidCreatePersonRequest)
  }
  
}

extension AddressViewModel {
  func actionLogout() {
    logout()
  }

  private func logout() {
    Task {
      defer {
        isLoading = false
      }
      isLoading = true
      do {
        async let deregisterEntity = deviceDeregisterUseCase.execute(deviceId: LFUtilities.deviceId, token: UserDefaults.lastestFCMToken)
        async let logoutEntity = accountRepository.logout()
        let deregister = try await deregisterEntity
        let logout = try await logoutEntity
        
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        customerSupportService.pushEventLogout()
        pushNotificationService.signOut()
        featureFlagManager.signOut()
        
        log.debug(deregister)
        log.debug(logout)
      } catch {
        log.error(error.userFriendlyMessage)
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
