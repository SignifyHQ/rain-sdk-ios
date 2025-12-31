import BaseOnboarding
import Combine
import Factory
import Foundation
import LFStyleGuide
import OnboardingData
import OnboardingDomain

@MainActor
public final class WaitlistViewModel: ObservableObject {
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  
  @Published var waitlistType: WaitlistType = .country
  
  @Published var isShowingCountrySelection: Bool = false
  @Published var isShowingStateSelection: Bool = false
  // Only show the unsupported countries here
  @Published var countryList: [Country] = Country.unsupportedCountries
  @Published var selectedCountry: Country?
  @Published var selectedCountryDisplayValue: String = .empty
  @Published var countrySearchQuery: String = .empty
  
  @Published private var stateList: [UsState] =  UsState.allCases
  @Published var stateListFiltered: [UsState] =  UsState.allCases
  @Published var selectedState: UsState?
  @Published var selectedStateDisplayValue: String = .empty
  @Published var stateSearchQuery: String = .empty
  
  @Published var emailAddress: String = .empty
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  @Published var shouldDismissSelf: Bool = false
  
  lazy var getUnsupportedStatesUseCase: GetUnsupportedStatesUseCaseProtocol = {
    return GetUnsupportedStatesUseCase(repository: onboardingRepository)
  }()
  
  lazy var joinWaitlistUseCase: JoinWaitlistUseCaseProtocol = {
    return JoinWaitlistUseCase(repository: onboardingRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    let isCountrySelected: Bool = waitlistType == .country && selectedCountry != nil
    let isStateSelected: Bool = waitlistType == .state && selectedState != nil
    
    return emailAddress.isValidEmail() && (isCountrySelected || isStateSelected)
  }
  
  init(
    waitlistType: WaitlistType
  ) {
    self.waitlistType = waitlistType
    
    bindCountryStateSelection()
    bindSearchQueries()
    
    getUnsupportedStates()
  }
}

// MARK: - Binding Observables
extension WaitlistViewModel {
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
          return Country.unsupportedCountries
        }
        
        return Country.unsupportedCountries.filter { country in
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

// MARK: - Handling UI/UX Logic
extension WaitlistViewModel {}

// MARK: - Handling Interations
extension WaitlistViewModel {
  func onContinueButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        // Attempt to join the waitlist with the selected country/state
        try await joinWaitlist()
        // Present a success toast which is aware of your selection
        let selectedRegion = waitlistType == .country ? selectedCountry?.title : selectedState?.name
        currentToast = ToastData(type: .success, title: "We’ll notify you when we are available in \(selectedRegion ?? "your region")!")
        // Wait for one second before dismissing the sheet to make sure the toast is readable
        try await Task.sleep(for: .seconds(1))
        shouldDismissSelf = true
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - API Calls
extension WaitlistViewModel {
  private func joinWaitlist(
  ) async throws {
    let parameters = JoinWaitlistParameters(
      // We pass the selected country if it is the country waitlist,
      // In case it is the waitlist for US state, we hardcode US
      countryCode: selectedCountry?.rawValue ?? Country.US.rawValue,
      // StateCode is only passed for US, otherwise it will be nil
      stateCode: selectedState?.rawValue,
      firstName: "User",
      lastName: "Name",
      email: emailAddress.trimWhitespacesAndNewlines()
    )
    
    try await joinWaitlistUseCase.execute(parameters: parameters)
  }
  
  private func getUnsupportedStates(
  ) {
    Task {
      do {
        let unsupportedStates = try await getUnsupportedStatesUseCase
          .execute(
            parameters: UnsupportedStateParameters(countryCode: "US")
          )
          .compactMap { state in
            UsState(rawValue: state.stateCode)
          }
        
        stateList = unsupportedStates
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - Helper Functions
extension WaitlistViewModel {}

// MARK: - Private Enums
extension WaitlistViewModel {
  enum WaitlistType {
    case country
    case state
  }
}
