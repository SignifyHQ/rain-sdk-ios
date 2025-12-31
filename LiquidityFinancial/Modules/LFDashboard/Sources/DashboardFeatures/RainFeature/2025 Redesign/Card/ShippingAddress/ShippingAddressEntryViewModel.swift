import BaseOnboarding
import SwiftUI
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import OnboardingData
import OnboardingDomain
import PlacesData
import PlacesDomain

@MainActor
public final class ShippingAddressEntryViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.placesRepository) var placesRepository
  
  var shippingAddress: ShippingAddress?
  
  @Published var areAddressComponentsLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  @Published var navigation: Navigation?
  
  @Published var isShowingStateSelection: Bool = false
  @Published var isShowingCountrySelection: Bool = false
  @Published var isShowingAddressSuggestions: Bool = false
  
  @Published var countryList: [Country] = Country.supportedCountries
  @Published var selectedCountry: Country?
  @Published var selectedCountryDisplayValue: String = .empty
  @Published var countrySearchQuery: String = .empty
  
  @Published var addressLine1: String = .empty
  @Published var addressLine2: String = .empty
  @Published var city: String = .empty
  @Published var zipCode: String = .empty
  
  @Published var stateList: [UsState] = UsState.allCases
  @Published var stateListFiltered: [UsState] = UsState.allCases
  @Published var selectedState: UsState?
  @Published var selectedStateDisplayValue: String = .empty
  @Published var stateSearchQuery: String = .empty
  
  @Published var unsupportedStateList: [UsState] =  []
  
  @Published var addressSuggestionList: [PlaceSuggestionModel] = []
  
  @Published var isFreeInputEnabled: Bool = false
  
  lazy var getAddressSuggestionsUseCase: GetAddressSuggestionsUseCaseProtocol = {
    return GetAddressSuggestionsUseCase(repository: placesRepository)
  }()
  
  lazy var getAutofillAddressUseCase: GetAutofillAddressUseCaseProtocol = {
    return GetAutofillAddressUseCase(repository: placesRepository)
  }()
  
  lazy var getUnsupportedStatesUseCase: GetUnsupportedStatesUseCaseProtocol = {
    return GetUnsupportedStatesUseCase(repository: onboardingRepository)
  }()
  
  private var pauseAutocomplete = false
  private var cancellables = Set<AnyCancellable>()
  
  var isConfirmButtonEnabled: Bool {
    !addressLine1.isTrimmedStringEmpty() &&
    !city.isTrimmedStringEmpty() &&
    (!zipCode.isTrimmedStringEmpty() || (isFreeInputEnabled && selectedCountry?.isUnitedStates == false)) &&
    (!selectedStateDisplayValue.isTrimmedStringEmpty() || (isFreeInputEnabled && selectedCountry?.isUnitedStates == false)) &&
    selectedCountry != nil
  }
  
  let onOrderSuccess: ((CardModel) -> Void)?
  init(onOrderSuccess: ((CardModel) -> Void)?) {
    self.onOrderSuccess = onOrderSuccess
    
    bindCountryStateSelection()
    bindSearchQueries()
    observeAddressSuggestion()
    
    getUnsupportedStates()
  }
}

// MARK: - Binding Observables
extension ShippingAddressEntryViewModel {
  private func bindCountryStateSelection() {
    $selectedCountry
      .map { country in
        if country?.isUnitedStates == true {
          self.selectedState = self.selectedState
        }
        
        return country?.title ?? ""
      }
      .assign(
        to: &$selectedCountryDisplayValue
      )
    
    $selectedState
      .map { state in
        state?.name ?? .empty
      }
      .assign(
        to: &$selectedStateDisplayValue
      )
  }
  
  private func bindSearchQueries() {
    $countrySearchQuery
      .map { searchQuery in
        let trimmedQuery = searchQuery.trimWhitespacesAndNewlines().lowercased()
        
        guard !trimmedQuery.isEmpty
        else {
          return Country.supportedCountries
        }
        
        return Country.supportedCountries.filter { country in
          country.title.lowercased().contains(trimmedQuery) || country.rawValue.lowercased().contains(trimmedQuery)
        }
      }
      .assign(
        to: &$countryList
      )
    
    Publishers
      .CombineLatest(
        $stateSearchQuery,
        $stateList
      )
      .map { searchQuery, allCases in
        let trimmedQuery = searchQuery.trimWhitespacesAndNewlines().lowercased()
        
        guard !trimmedQuery.isEmpty
        else {
          return allCases
        }
        
        return allCases.filter { state in
          state.name.lowercased().contains(trimmedQuery) || state.rawValue.lowercased().contains(trimmedQuery)
        }
      }
      .assign(
        to: &$stateListFiltered
      )
  }
  
  private func observeAddressSuggestion() {
    $addressLine1
      .debounce(
        for: .seconds(0.5),
        scheduler: RunLoop.main
      )
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
}

//MARK: - API Calls
extension ShippingAddressEntryViewModel {
  private func getUnsupportedStates() {
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
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
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
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
  
  private func fetchAddressComponens(
    placeId: String
  ) {
    Task {
      defer {
        areAddressComponentsLoading = false
      }
      
      areAddressComponentsLoading = true
      
      do {
        let addressComponents = try await getAutofillAddressUseCase.execute(placeId: placeId)
        // Do not prefill address if the country is not supported
        guard let suggestedCountry = Country(title: addressComponents.country ?? .empty),
              Country.supportedCountries.contains(suggestedCountry)
        else {
          return
        }
        
        addressLine1 = addressComponents.street ?? .empty
        city = addressComponents.city ?? .empty
        selectedCountry = suggestedCountry
        zipCode = addressComponents.postalCode ?? .empty
        
        if selectedCountry == .US {
          let state = UsState(name: addressComponents.state ?? .empty) ?? .AL
          // Check if the state is not blocked
          if !unsupportedStateList.contains(state) {
            selectedState = state
          }
        } else {
          selectedStateDisplayValue = addressComponents.state ?? .empty
        }
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - Handling Interations
extension ShippingAddressEntryViewModel {
  func hideSelections() {
    isShowingStateSelection = false
    isShowingCountrySelection = false
    isShowingAddressSuggestions = false
  }
  
  func onSuggestionSelected(
    suggestion: PlaceSuggestionModel
  ) {
    pauseAutocomplete = true
    isShowingAddressSuggestions = false
    
    fetchAddressComponens(placeId: suggestion.placeId)
  }
  
  func onConfirmButtonTap() {
    guard let selectedCountry else { return }
    
    let state = selectedCountry.isUnitedStates ? selectedState?.rawValue : selectedStateDisplayValue.trimWhitespacesAndNewlines()
    
    if !isFreeInputEnabled && (state == nil || state?.isEmpty == true) {
      return
    }
    
    shippingAddress = ShippingAddress(
      line1: addressLine1,
      line2: addressLine2,
      city: city,
      state: state ?? .empty,
      postalCode: zipCode,
      country: selectedCountry,
      requiresVerification: isFreeInputEnabled
    )
    navigation = .cardOrderConfirmation
  }
  
  func onCouldNotFindAddressTap() {
    withAnimation {
      isFreeInputEnabled = true
    }
  }
}

// MARK: - Private Enums and Structs
extension ShippingAddressEntryViewModel {
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
  
  enum Navigation {
    case cardOrderConfirmation
  }
}
