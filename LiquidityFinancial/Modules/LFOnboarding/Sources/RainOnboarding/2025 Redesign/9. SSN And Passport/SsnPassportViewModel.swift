import BaseOnboarding
import Combine
import Factory
import Foundation
import FraudForce
import LFLocalizable
import LFStyleGuide
import LFUtilities
import RainData
import RainDomain

@MainActor
public final class SsnPassportViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.rainRepository) var rainRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  let additionalProfileInformation: AdditionalProfileInformation
  
  var selectedCountry: Country = .US
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var ssnPassport: String = .empty
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  lazy var createRainAccountUseCase: CreateRainAccountUseCaseProtocol = {
    return CreateRainAccountUseCase(repository: rainRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    guard selectedCountry.isUnitedStates
    else {
      return ssnPassport.trimWhitespacesAndNewlines().count >= 3
    }
    
    return ssnPassport.stripToDigits.count == 9
  }
  
  init(
    additionalProfileInformation: AdditionalProfileInformation
  ) {
    // The additional profile information is passed from the previous step
    self.additionalProfileInformation = additionalProfileInformation
    // Set the selected country to provide US/International experience
    if let countryCode = accountDataManager.userInfomationData.countryCode,
       let country = Country(rawValue: countryCode) {
      selectedCountry = country
    }
  }
}

// MARK: - Binding Observables
extension SsnPassportViewModel {}

// MARK: - Handling UI/UX Logic
extension SsnPassportViewModel {}

// MARK: - Handling Interations
extension SsnPassportViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        // Atempt to create a Rain user
        try await createRainUser()
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

// MARK: - API Calls
extension SsnPassportViewModel {
  private func createRainUser() async throws {
    // Build the parameters for create Rain user call
    let parameters = createRainPersonParameters()
    // Call the endpoint to create Rain user
    _ = try await createRainAccountUseCase.execute(parameters: parameters)
  }
}

// MARK: - Helper Functions
extension SsnPassportViewModel {
  func createRainPersonParameters() -> APIRainPersonParameters {
    let rainAddress = RainAddressParameters(
      line1: accountDataManager.userInfomationData.addressLine1 ?? .empty,
      line2: accountDataManager.userInfomationData.addressLine2 ?? .empty,
      city: accountDataManager.userInfomationData.city ?? .empty,
      region: accountDataManager.userInfomationData.state ?? .empty,
      postalCode: accountDataManager.userInfomationData.postalCode ?? .empty,
      countryCode: selectedCountry.rawValue,
      country: selectedCountry.title
    )
    
    return APIRainPersonParameters(
      firstName: accountDataManager.userInfomationData.firstName ?? .empty,
      lastName: accountDataManager.userInfomationData.lastName ?? .empty,
      birthDate: accountDataManager.userInfomationData.dateOfBirth ?? .empty,
      nationalId: selectedCountry.isUnitedStates ? ssnPassport.trimWhitespacesAndNewlines().trimmedPhoneNumberOrSsn : ssnPassport.trimWhitespacesAndNewlines(),
      countryOfIssue: selectedCountry.rawValue,
      email: accountDataManager.userInfomationData.email ?? .empty,
      address: rainAddress,
      phoneCountryCode: accountDataManager.phoneCode,
      phoneNumber: accountDataManager.phoneNumber,
      occupation: additionalProfileInformation.occupation,
      annualSalary: additionalProfileInformation.annualSalary,
      accountPurpose: additionalProfileInformation.accountPurpose,
      expectedMonthlyVolume: additionalProfileInformation.expectedMonthlyVolume,
      iovationBlackbox: FraudForce.blackbox()
    )
  }
}

// MARK: - Private Enums
extension SsnPassportViewModel {}
