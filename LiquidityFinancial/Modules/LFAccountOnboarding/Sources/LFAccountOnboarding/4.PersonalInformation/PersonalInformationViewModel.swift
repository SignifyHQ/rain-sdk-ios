import SwiftUI
import Factory
import OnboardingData
import LFUtilities

class PersonalInformationViewModel: ObservableObject {
  enum PersonalInfoError: Error, LocalizedError {
    case invalidFirstName
    case invalidLastName
    case invalidEmail
    case invalidDob

    /// API related custom error title
    var errorDescription: String? {
      switch self {
      case .invalidFirstName:
        return "Invalid First Name"
      case .invalidLastName:
        return "Invalid Last Name"
      case .invalidEmail:
        return "Invalid Email"
      case .invalidDob:
        return "Invalid DOB"
      }
    }
  }

  @Injected(\Container.userDataManager) var userDataManager
  
  @Published var isNavigationToSSNView: Bool = false
  @Published var isActionAllowed: Bool = false {
    didSet {
      guard isActionAllowed else { return }
      userDataManager.update(email: email)
      userDataManager.update(firstName: firstName)
      userDataManager.update(lastName: lastName)
      userDataManager.update(dateOfBirth: dateCheck?.netspendDate())
      userDataManager.userNameDisplay = firstName
      if userDataManager.userInfomationData.phone == nil {
        userDataManager.update(phone: UserDefaults.phoneNumber)
      }
    }
  }
  @Published var errorObj: Error?

  @Published var firstName: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var lastName: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var email: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var dob: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var dateCheck: Date? {
    didSet {
      isAllDataFilled()
    }
  }
  
  func openIntercom() {
      // TODO: Will be implemented later
      // intercomService.openIntercom()
  }
}

private extension PersonalInformationViewModel {
  func isAllDataFilled() {
    isActionAllowed = (!firstName.trimWhitespacesAndNewlines().isEmpty &&
      !lastName.trimWhitespacesAndNewlines().isEmpty &&
      !email.trimWhitespacesAndNewlines().isEmpty &&
      dateCheck != nil) && email.trimWhitespacesAndNewlines().isValidEmail()
  }

  func validate(_ completion: @escaping (Result<Bool, PersonalInfoError>) -> Void) {
    if firstName.trimWhitespacesAndNewlines().isEmpty {
      completion(.failure(.invalidFirstName))
    } else if lastName.trimWhitespacesAndNewlines().isEmpty {
      completion(.failure(.invalidLastName))
    } else if email.trimWhitespacesAndNewlines().isEmpty {
      completion(.failure(.invalidEmail))
    } else if !email.trimWhitespacesAndNewlines().isValidEmail() {
      completion(.failure(.invalidEmail))
    } else if dob.trimWhitespacesAndNewlines().isEmpty {
      completion(.failure(.invalidDob))
    } else {
      completion(.success(true))
    }
  }
}
