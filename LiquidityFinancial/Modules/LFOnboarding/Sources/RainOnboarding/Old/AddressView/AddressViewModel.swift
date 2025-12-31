import BaseOnboarding
import Combine
import DevicesData
import DevicesDomain
import Factory
import FraudForce
import GooglePlacesSwift
import LFLocalizable
import LFUtilities
import OnboardingData
import OnboardingDomain
import PlacesData
import PlacesDomain
import Services

@MainActor
final class AddressViewModel: ObservableObject {
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.placesRepository) var placesRepository
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isLoading: Bool = false
  @Published var isAddressComponentsLoading: Bool = false
  @Published var shouldProceedToNextStep: Bool = false
  
  @Published var isShowingCountrySelection: Bool = false
  @Published var isShowingStateSelection: Bool = false
  @Published var isShowingAddressSuggestions: Bool = false
  
  @Published var shouldEnableContinueButton: Bool = false

  @Published var addressLine1: String = .empty
  @Published var addressLine2: String = .empty
  @Published var city: String = .empty
  @Published var state: String = .empty
  @Published var zipCode: String = .empty
  @Published var toastMessage: String?
  
  @Published var popup: Popup?
  @Published var addressSuggestionList: [PlaceSuggestionModel] = []
  
  @Published var countryCodeList: [Country] = Country.allCases
  @Published var selectedCountry: Country = .US
  @Published var selectedCountryTitle: String = .empty
  
  @Published var stateList: [UsState] =  UsState.allCases
  @Published var selectedState: UsState = .AL
  @Published var shouldUseStateDropdown: Bool = true
  
  @Published var isShowingWaitlistStateSelection: Bool = false
  @Published var shouldPresentGetNotifiedPopup: Bool = false
  
  @Published var unsupportedStateList: [UsState] =  []
  @Published var selectedWaitlistState: UsState?
  
  @Published var waitlistState: String = .empty
  @Published var waitlistEmail: String = .empty
  
  @Published var isLoadingWaitlist: Bool = false

  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
    return DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  
  lazy var getAddressSuggestionsUseCase: GetAddressSuggestionsUseCaseProtocol = {
    return GetAddressSuggestionsUseCase(repository: placesRepository)
  }()
  
  lazy var getAutofillAddressUseCase: GetAutofillAddressUseCaseProtocol = {
    return GetAutofillAddressUseCase(repository: placesRepository)
  }()
  
  lazy var getUnsupportedStatesUseCase: GetUnsupportedStatesUseCaseProtocol = {
    return GetUnsupportedStatesUseCase(repository: onboardingRepository)
  }()
  
  lazy var joinWaitlistUseCase: JoinWaitlistUseCaseProtocol = {
    return JoinWaitlistUseCase(repository: onboardingRepository)
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
          self?.selectedState = .AL
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
    
    $selectedWaitlistState
      .map { state in
        state?.name ?? ""
      }
      .assign(
        to: &$waitlistState
      )
  }
  
  func onAppear() {
    getUnsupportedStates()
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
  
  var isWaitlistButtonActive: Bool {
    selectedWaitlistState != nil && waitlistEmail.trimWhitespacesAndNewlines().isValidEmail()
  }
  
  func getUnsupportedStates() {
    Task {
      do {
        let unsupportedStates = try await getUnsupportedStatesUseCase
          .execute(
            parameters: UnsupportedStateParameters(countryCode: "US")
          )
          .compactMap { state in
            UsState(rawValue: state.stateCode)
          }
        
        stateList = UsState.allCases.filter { state in
          !unsupportedStates.contains(state)
        }
        unsupportedStateList = unsupportedStates
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func joinWaitlist() {
    Task {
      defer {
        isLoadingWaitlist = false
      }
      
      isLoadingWaitlist = true
      
      do {
        let parameters = JoinWaitlistParameters(
          countryCode: "US",
          stateCode: selectedWaitlistState?.rawValue ?? "n/a",
          firstName: accountDataManager.userInfomationData.firstName ?? "n/a",
          lastName: accountDataManager.userInfomationData.lastName ?? "n/a",
          email: waitlistEmail.lowercased()
        )
        
        try await joinWaitlistUseCase.execute(parameters: parameters)
        
        toastMessage = L10N.Common.YourAddress.Waitlist.SuccessToast.title
        shouldPresentGetNotifiedPopup = false
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
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
  
  func select(
    suggestion: PlaceSuggestionModel
  ) {
    pauseAutocomplete = true
    isShowingAddressSuggestions = false
    
    fetchAddressComponens(placeId: suggestion.placeId)
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
        guard let self = self
        else {
          return
        }
        
        guard !self.pauseAutocomplete
        else {
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
  
  private func fetchAddressSuggestion(
    query: String
  ) {
    Task {
      guard query.count > 2
      else {
        isShowingAddressSuggestions = false
        
        return
      }
      
      do {
        let suggestions = try await getAddressSuggestionsUseCase.execute(query: query).map { entity in
          PlaceSuggestionModel(entity: entity)
        }
        
        addressSuggestionList = suggestions
        isShowingAddressSuggestions = true
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  private func fetchAddressComponens(
    placeId: String
  ) {
    Task {
      defer {
        isAddressComponentsLoading = false
      }
      
      isAddressComponentsLoading = true
      
      do {
        let addressComponents = try await getAutofillAddressUseCase.execute(placeId: placeId)
        
        addressLine1 = addressComponents.street ?? .empty
        city = addressComponents.city ?? .empty
        selectedCountry = Country(title: addressComponents.country ?? .empty) ?? .US
        zipCode = addressComponents.postalCode ?? .empty
        
        if selectedCountry == .US {
          selectedState = UsState(name: addressComponents.state ?? .empty) ?? .AL
        } else {
          state = addressComponents.state ?? .empty
        }
      } catch {
        toastMessage = error.userFriendlyMessage
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

extension AddressViewModel {
  struct PlaceSuggestionModel: PlaceSuggestionEntity, Identifiable {
    var id: String {
      placeId
    }
    
    var placeId: String
    var title: String
    
    init(
      entity: PlaceSuggestionEntity
    ) {
      self.placeId = entity.placeId
      self.title = entity.title
    }
  }
}
