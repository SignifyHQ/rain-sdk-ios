import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import RainData
import RainDomain

@MainActor
public final class AgreeToCardTermsViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainRepository) var rainRepozitory
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var selectedCountry: Country = .US
  
  @Published var areCardTermsAgreed: Bool = false
  @Published var isInfoAccurateAgreed: Bool = false
  @Published var isAcknowledgmentAgreed: Bool = false
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  lazy var rainAcceptTermsUseCase: RainAcceptTermsUseCaseProtocol = {
    RainAcceptTermsUseCase(repository: rainRepozitory)
  }()
  
  var isContinueButtonEnabled: Bool {
    return areCardTermsAgreed && isInfoAccurateAgreed && isAcknowledgmentAgreed
  }
  
  let accountDisclosures = "Opening Account Privacy Disclosures"
  let cardTerms = "Card Terms"
  let privacyPolicy = "Issuer Privacy Policy"
  
  init() {
    // Set the selected country to provide US/International experience
    if let countryCode = accountDataManager.userInfomationData.countryCode,
       let country = Country(rawValue: countryCode) {
      selectedCountry = country
    }
  }
}

// MARK: - Binding Observables
extension AgreeToCardTermsViewModel {}

// MARK: - Handling UI/UX Logic
extension AgreeToCardTermsViewModel {}

// MARK: - Handling Interations
extension AgreeToCardTermsViewModel {
  func onContinueButtonTap() {
    saveTermsAgreement()
  }
}

// MARK: - Handling API Calls
extension AgreeToCardTermsViewModel {
  private func saveTermsAgreement() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        // Attempt to call the endpoint for accepting terms
        try await rainAcceptTermsUseCase.execute()
        // Navigate to the next step on success
        navigation = try await onboardingCoordinator.getOnboardingNavigation()
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
extension AgreeToCardTermsViewModel {
  func getURL(
    tappedString: String
  ) -> URL? {
    let urlMapping: [String: String] = [
      accountDisclosures: LFUtilities.accountDisclosureURL,
      cardTerms: selectedCountry.isUnitedStates ? LFUtilities.cardTermsURLUs : LFUtilities.cardTermsURLInt,
      privacyPolicy: LFUtilities.issuerPrivacyPolicyURL
    ]
    
    return urlMapping[tappedString].flatMap { URL(string: $0) }
  }
}

// MARK: - Private Enums
extension AgreeToCardTermsViewModel {
  enum SafariNavigation: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case accountDisclosures
    case cardTerms
    case privacyPolicy
  }
}
