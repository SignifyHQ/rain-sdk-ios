import SwiftUI
import Factory
import AccountData
import LFUtilities
import Services

public enum PersonalInformationNavigation {
  case enterSSN(AnyView)
}

@MainActor
public final class PersonalInformationViewModel: ObservableObject {
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
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isActionAllowed: Bool = false {
    didSet {
      guard isActionAllowed else { return }
      accountDataManager.update(email: email)
      accountDataManager.update(firstName: firstName)
      accountDataManager.update(lastName: lastName)
      accountDataManager.update(fullName: firstName + " " + lastName)
      accountDataManager.update(dateOfBirth: dateCheck?.getDateString())
      accountDataManager.userNameDisplay = firstName
      accountDataManager.userEmail = email
      if accountDataManager.userInfomationData.phone == nil {
        accountDataManager.update(phone: UserDefaults.phoneNumber)
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
  
  public init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
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
