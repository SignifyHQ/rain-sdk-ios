import BaseOnboarding
import Combine
import DevicesData
import DevicesDomain
import Factory
import FraudForce
import LFUtilities
import Services
import SmartyStreets

@MainActor
final class AddressViewModel: ObservableObject {
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isLoading: Bool = false
  @Published var shouldProceedToNextStep: Bool = false
  
  @Published var isShowingCountrySelection: Bool = false
  @Published var isShowingStateSelection: Bool = false
  
  @Published var displaySuggestions: Bool = false
  @Published var shouldEnableContinueButton: Bool = false

  @Published var addressLine1: String = .empty
  @Published var addressLine2: String = .empty
  @Published var city: String = .empty
  @Published var state: String = .empty
  @Published var zipCode: String = .empty
  @Published var toastMessage: String?
  
  @Published var popup: Popup?
  @Published var addressList: [AddressData] = []
  
  @Published var countryCodeList: [Country] = Country.allCases
  @Published var selectedCountry: Country = .US
  @Published var selectedCountryTitle: String = .empty
  
  @Published var stateList: [UsState] =  UsState.allCases
  @Published var selectedState: UsState = .AK
  @Published var shouldUseStateDropdown: Bool = true

  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
    return DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  
  private var isStateValid = true
  private var pauseAutocomplete = false
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    observeUserInput()
    observeAddressSuggestion()
    bindCountryStateSelection()
  }
}


// MARK: - View Handle
extension AddressViewModel {
  private func bindCountryStateSelection() {
    $selectedCountry
      .map { [weak self] country in
        if country == .US {
          self?.selectedState = .AK
        }
        
        self?.shouldUseStateDropdown = country == .US
        
        return country.title
      }
      .assign(
        to: &$selectedCountryTitle
      )
    
    $selectedState
      .map { state in
        state.rawValue
      }
      .assign(
        to: &$state
      )
  }
  
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewedAddress))
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTapped() {
    updateUserInformation()
    analyticsService.track(event: AnalyticsEvent(name: .addressCompleted))
    
    shouldProceedToNextStep = true
  }
  
  func logout() {
    Task {
      defer {
        isLoading = false
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        customerSupportService.pushEventLogout()
        popup = nil
        pushNotificationService.signOut()
        featureFlagManager.signOut()
      }
      isLoading = true
      
      do {
        let deregisterEntity = try await deviceDeregisterUseCase.execute(
          deviceId: LFUtilities.deviceId,
          token: UserDefaults.lastestFCMToken
        )
        let logoutEntity = try await accountRepository.logout()
        
        log.debug(deregisterEntity)
        log.debug(logoutEntity)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
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
}

// MARK: - Private Functions
private extension AddressViewModel {
  func observeUserInput() {
    Publishers.CombineLatest4($addressLine1, $addressLine2, $city, $zipCode)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _, _, _, _ in
        self?.isAllDataFilled()
      }
      .store(in: &cancellables)
    
    $state
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        guard let self else { return }
        
        self.isAllDataFilled()
        self.checkStateValid(state: state.uppercased())
      }
      .store(in: &cancellables)
  }
  
  func observeAddressSuggestion() {
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
        
        self.fetchAddressSuggestion(query: value.capitalized)
      }
      .store(in: &cancellables)
  }
  
  func isAllDataFilled() {
    let requiredFields: [String] = [
      addressLine1.trimWhitespacesAndNewlines(),
      city.trimWhitespacesAndNewlines(),
      state.trimWhitespacesAndNewlines(),
      zipCode.trimWhitespacesAndNewlines()
    ]
    
    shouldEnableContinueButton = requiredFields.allSatisfy { !$0.isEmpty }
  }
  
  func checkStateValid(state: String) {
    guard LFUtilities.cryptoEnabled else {
      self.isStateValid = true
      return
    }
    
    isStateValid = !Constants.unSupportedStates.contains(state)
  }
  
  func updateUserInformation() {
    accountDataManager.update(addressLine1: addressLine1)
    accountDataManager.update(addressLine2: addressLine2)
    accountDataManager.update(city: city)
    accountDataManager.update(state: state)
    accountDataManager.update(postalCode: zipCode)
    accountDataManager.update(country: selectedCountry.rawValue.uppercased())
  }
  
  func fetchAddressSuggestion(query: String) {
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
          addressline1: $0.streetLine ?? .empty,
          city: $0.city ?? .empty,
          state: $0.state ?? .empty,
          zipcode: $0.zipcode ?? .empty
        )
      } ?? []
      
      DispatchQueue.main.async {
        self?.addressList = suggestions
        self?.displaySuggestions = !suggestions.isEmpty
      }
    }
  }
}

// MARK: - Types
extension AddressViewModel {
  enum Popup {
    case waitlist(String)
    case waitlistJoined
  }
}
