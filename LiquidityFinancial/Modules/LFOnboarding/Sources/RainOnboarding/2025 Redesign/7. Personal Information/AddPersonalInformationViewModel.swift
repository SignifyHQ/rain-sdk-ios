import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFUtilities

@MainActor
public final class AddPersonalInformationViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var authMethod: AuthMethod = .email
  
  @Published var navigation: Navigation?
  
  @Published var isShowingPhoneCodeCountrySelection: Bool = false
  
  @Published var countryList: [Country] = Country.allCases
  @Published var selectedCountry: Country = .US
  @Published var selectedCountryDisplayValue: String = .empty
  @Published var countrySearchQuery: String = .empty
  
  @Published var firstName: String = .empty
  @Published var lastName: String = .empty
  @Published var dob: String = .empty
  @Published var phoneNumber: String = .empty
  @Published var emailAddress: String = .empty
  
  @Published var selectedDate: Date?
  @Published var dobInputError: String?
  
  var isContinueButtonEnabled: Bool {
    let additionalInformationValid: Bool = {
      let emailValid = authMethod == .phone && (emailAddress.isValidEmail() == true)
      let phoneValid = authMethod == .email && (phoneNumber.reformatPhone.count >= Constants.MinCharacterLimit.phoneNumber.value)
      
      return emailValid || phoneValid
    }()
    
    let isDobValid: Bool = {
      guard let selectedDate
      else {
        return false
      }
      
      return selectedDate.isAtLeast18()
    }()
    
    return !firstName.isTrimmedStringEmpty() &&
    !lastName.isTrimmedStringEmpty() &&
    isDobValid &&
    additionalInformationValid
  }
  
  init(
  ) {
    bindStateSelection()
    bindSearchQueries()
    bindDobCheck()
    
    // Set the selected country to pre-fill the phone code if needed
    if let countryCode = accountDataManager.userInfomationData.countryCode,
       let country = Country(rawValue: countryCode) {
      selectedCountry = country
    }
    // Check if the email was used as auth method to determine whether
    // we need to ask for email address or phone number
    self.authMethod = accountDataManager.userInfomationData.email == nil ? .phone : .email
  }
}

// MARK: - Binding Observables
extension AddPersonalInformationViewModel {
  private func bindStateSelection() {
    $selectedCountry
      .map { country in
        country.flagEmoji() + country.phoneCode
      }
      .assign(
        to: &$selectedCountryDisplayValue
      )
  }
  
  private func bindSearchQueries() {
    $countrySearchQuery
      .map { searchQuery in
        let trimmedQuery = searchQuery.trimWhitespacesAndNewlines().lowercased()
        
        guard !trimmedQuery.isEmpty
        else {
          return Country.allCases
        }
        
        return Country.allCases.filter { country in
          country.title.lowercased().contains(trimmedQuery) || country.rawValue.lowercased().contains(trimmedQuery)
        }
      }
      .assign(
        to: &$countryList
      )
  }
  
  private func bindDobCheck() {
    $selectedDate
      .map { date in
        let isAtLeast18 = date?.isAtLeast18() ?? true

        return isAtLeast18 == true ? nil : "Sorry! You must be at least 18 years old to open an\naccount"
      }
      .assign(
        to: &$dobInputError
      )
  }
}

// MARK: - Handling UI/UX Logic
extension AddPersonalInformationViewModel {
}

// MARK: - Handling Interations
extension AddPersonalInformationViewModel {
  func onSupportButtonTap() {
    hideSelections()
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    // Store the missing email if the auth method is phone number
    if authMethod == .phone {
      accountDataManager.update(email: emailAddress.trimWhitespacesAndNewlines())
      // TODO (Volo): - Check if we need the below code and remove if not
      accountDataManager.userEmail = emailAddress.trimWhitespacesAndNewlines()
    }
    // Store the missing phone number if the auth method is email address
    if authMethod == .email {
      accountDataManager.update(phone: apiRequestFormattedPhoneNumber)
      // TODO (Volo): - Check if we need the below code and remove if not
      accountDataManager.phoneCode = selectedCountry.phoneCode
      accountDataManager.phoneNumber = phoneNumber.trimmedPhoneNumberOrSsn
    }
    // Store the rest of the user information
    accountDataManager.update(firstName: firstName.trimWhitespacesAndNewlines())
    accountDataManager.update(lastName: lastName.trimWhitespacesAndNewlines())
    accountDataManager.update(fullName: (firstName + " " + lastName).trimWhitespacesAndNewlines())
    // Format and store the DoB
    if let selectedDate {
      let dateOfBirthFormatted = LiquidityDateFormatter.simpleDate.parseToString(from: selectedDate)
      accountDataManager.update(dateOfBirth: dateOfBirthFormatted)
    }
    // Hide all dropdowns when the user taps `Continue`
    hideSelections()
    // Navigate to the next step
    navigation = .completeYourProfile
  }
  
  func hideSelections() {
    isShowingPhoneCodeCountrySelection = false
  }
}

// MARK: - Helper Functions
extension AddPersonalInformationViewModel {
  private var apiRequestFormattedPhoneNumber: String? {
    let fullPhoneNumber = selectedCountry.phoneCode + phoneNumber
    let phoneNumberTrimmed = fullPhoneNumber.trimmedPhoneNumberOrSsn
    
    return authMethod == .phone ? phoneNumberTrimmed : nil
  }
}

// MARK: - Private Enums
extension AddPersonalInformationViewModel {
  enum Navigation {
    case completeYourProfile
  }
  
  enum AuthMethod {
    case phone
    case email
  }
}
