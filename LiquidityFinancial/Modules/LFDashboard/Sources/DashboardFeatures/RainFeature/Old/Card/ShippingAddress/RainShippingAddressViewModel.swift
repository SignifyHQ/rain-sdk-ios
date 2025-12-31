import BaseOnboarding
import Combine
import Factory
import SwiftUI
import Services
import SmartyStreets
import LFUtilities
import LFLocalizable
import OnboardingData
import OnboardingDomain
import PlacesData
import PlacesDomain

@MainActor
final class RainShippingAddressViewModel: ObservableObject {
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.placesRepository) var placesRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Binding var shippingAddress: ShippingAddress?
  
  @Published var isLoading: Bool = false
  @Published var isAddressComponentsLoading: Bool = false
  @Published var shouldEnableContinueButton: Bool = false
  
  @Published var isShowingCountrySelection: Bool = false
  @Published var isShowingStateSelection: Bool = false
  @Published var isShowingAddressSuggestions: Bool = false
  @Published var isFreeInputEnabled: Bool = false
  
  @Published var addressLine1: String = .empty
  @Published var addressLine2: String = .empty
  @Published var city: String = .empty
  @Published var state: String = .empty
  @Published var zipCode: String = .empty
  @Published var toastMessage: String?
  
  @Published var addressSuggestionList: [PlaceSuggestionModel] = []
  
  @Published var countryCodeList: [Country] = Country.allCases
  @Published var selectedCountry: Country?// = .US
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
  
  private var pauseAutocomplete = false
  private var cancellables = Set<AnyCancellable>()
  
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
  
  var isWaitlistButtonActive: Bool {
    selectedWaitlistState != nil && waitlistEmail.trimWhitespacesAndNewlines().isValidEmail()
  }
  
  var isValidAddressEntered: Bool {
    !addressLine1.isEmpty && !city.isEmpty && selectedCountry != nil && !state.isEmpty && !zipCode.isEmpty
  }
  
  init(
    shippingAddress: Binding<ShippingAddress?>
  ) {
    _shippingAddress = shippingAddress
    
    observeUserInput()
    observeAddressSuggestion()
    bindCountryStateSelection()
    
    addressLine1 = shippingAddress.wrappedValue?.line1 ?? String.empty
    addressLine2 = shippingAddress.wrappedValue?.line2 ?? String.empty
    city = shippingAddress.wrappedValue?.city ?? String.empty
    zipCode = shippingAddress.wrappedValue?.postalCode ?? String.empty
    selectedCountry = shippingAddress.wrappedValue?.country
    
    if selectedCountry == .US {
      selectedState = UsState(rawValue: shippingAddress.wrappedValue?.state ?? String.empty) ?? .AL
    } else {
      state = shippingAddress.wrappedValue?.state ?? String.empty
    }
  }
}

// MARK: - View Helpers
extension RainShippingAddressViewModel {
  private func bindCountryStateSelection() {
    $selectedCountry
      .map { [weak self] country in
        if country == .US {
          self?.selectedState = .AL
        }
        
        self?.shouldUseStateDropdown = country == .US
        
        return country?.title ?? ""
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
    isFreeInputEnabled = (shippingAddress?.requiresVerification == true)
  }
  
  func onCouldNotFindAddressTap() {
    isFreeInputEnabled = true
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func saveAddress() {
    guard let selectedCountry
    else {
      return
    }
    
    shippingAddress = ShippingAddress(
      line1: addressLine1,
      line2: addressLine2,
      city: city,
      state: state,
      postalCode: zipCode,
      country: selectedCountry,
      requiresVerification: isFreeInputEnabled
    )
  }
  
  func select(
    suggestion: PlaceSuggestionModel
  ) {
    pauseAutocomplete = true
    isShowingAddressSuggestions = false
    
    fetchAddressComponens(placeId: suggestion.placeId)
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
}

// MARK: - Private Functions
private extension RainShippingAddressViewModel {
  private func observeUserInput() {
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
      }
      .store(in: &cancellables)
  }

  private func observeAddressSuggestion() {
    $addressLine1
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .dropFirst(2)
      .removeDuplicates()
      .sink { [weak self] value in
        guard let self = self
        else {
          return
        }
        
        guard !pauseAutocomplete,
              !isFreeInputEnabled
        else {
          pauseAutocomplete = false
          
          return
        }
        
        clearAutocompleteData()
        fetchAddressSuggestion(query: value.capitalized)
      }
      .store(in: &cancellables)
  }
  
  private func fetchAddressSuggestion(
    query: String
  ) {
    Task {
      guard query.count > 2,
            !isFreeInputEnabled
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
        selectedCountry = Country(title: addressComponents.country ?? .empty)
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
  
  private func isAllDataFilled() {
    let requiredFields: [String] = [
      addressLine1.trimWhitespacesAndNewlines(),
      city.trimWhitespacesAndNewlines(),
      state.trimWhitespacesAndNewlines(),
      zipCode.trimWhitespacesAndNewlines()
    ]
    
    shouldEnableContinueButton = requiredFields.allSatisfy { !$0.isEmpty }
  }
  
  private func clearAutocompleteData() {
    city = .empty
    selectedCountry = nil
    state = .empty
    zipCode = .empty
  }
}

// MARK: - Types

extension RainShippingAddressViewModel {
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
