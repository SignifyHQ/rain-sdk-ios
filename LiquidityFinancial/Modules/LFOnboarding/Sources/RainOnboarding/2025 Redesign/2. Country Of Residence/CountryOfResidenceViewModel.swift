import BaseOnboarding
import Combine
import Factory
import Foundation
import LFStyleGuide
import OnboardingData
import OnboardingDomain

@MainActor
public final class CountryOfResidenceViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  
  var authMethod: AuthMethod
  
  @Published var navigation: Navigation?
  @Published var waitlistNavigation: WaitlistNavigation?
  
  @Published var isShowingCountrySelection: Bool = false
  @Published var isShowingStateSelection: Bool = false
  
  @Published var countryList: [Country] = Country.supportedCountries
  @Published var selectedCountry: Country?
  @Published var selectedCountryDisplayValue: String = .empty
  @Published var countrySearchQuery: String = .empty
  
  @Published private var stateList: [UsState] =  UsState.allCases
  @Published var stateListFiltered: [UsState] =  UsState.allCases
  @Published var selectedState: UsState?
  @Published var selectedStateDisplayValue: String = .empty
  @Published var stateSearchQuery: String = .empty
  
  @Published var currentToast: ToastData? = nil
  
  lazy var getUnsupportedStatesUseCase: GetUnsupportedStatesUseCaseProtocol = {
    return GetUnsupportedStatesUseCase(repository: onboardingRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    selectedCountry != nil && (selectedCountry != .US || selectedState != nil)
  }
  
  init(
    authMethod: AuthMethod
  ) {
    self.authMethod = authMethod
    
    bindCountryStateSelection()
    bindSearchQueries()
    
    getUnsupportedStates()
  }
}

// MARK: - Binding Observables
extension CountryOfResidenceViewModel {
  private func bindCountryStateSelection() {
    $selectedCountry
      .map { country in
        country?.title ?? .empty
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
}

// MARK: - Handling Interations
extension CountryOfResidenceViewModel {
  func onSupportButtonTap() {
    hideSelections()
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    // Store the selected country and state in order to pre-fill the phone code
    // and the country/state in address input screen
    if let selectedCountry {
      accountDataManager.update(countryCode: selectedCountry.rawValue)
    }
    // Store the state only if the US was selected
    if let selectedState {
      accountDataManager.update(state: selectedCountry?.isUnitedStates == true ? selectedState.rawValue : nil)
    }
    
    hideSelections()
    navigation = .authentication(authMethod: authMethod)
  }
  
  func onWaitlistButtonTap(
    shouldNavigateTo type: WaitlistNavigation
  ) {
    waitlistNavigation = type
  }
  
  private func hideSelections() {
    isShowingCountrySelection = false
    isShowingStateSelection = false
  }
}

// MARK: - API Calls
extension CountryOfResidenceViewModel {
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
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - Private Enums
extension CountryOfResidenceViewModel {
  enum Navigation {
    case authentication(authMethod: AuthMethod)
  }
  
  enum WaitlistNavigation: String, Identifiable {
    var id: String {
      rawValue
    }
    
    case country
    case state
  }
  
  enum AuthMethod {
    case phone
    case email
  }
}
