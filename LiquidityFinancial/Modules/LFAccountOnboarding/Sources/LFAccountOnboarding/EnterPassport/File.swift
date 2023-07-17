import SwiftUI

final class EnterPassportViewModel: ObservableObject {
  @Published var errorMessage: String?
  @Published var isActionAllowed: Bool = false
  @Published var showPassportTypes: Bool = false
  @Published var selectedPassport: PassportType = .international
  
  @State var selection: Int?
  @State var showIndicator = false
  @State var toastMessage: String?
  @FocusState var keyboardFocus: Bool

  @Published var passport: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
}

private extension EnterPassportViewModel {
  func isAllDataFilled() {
    isActionAllowed = (!passport.trimWhitespacesAndNewlines().isEmpty)
  }
}

extension EnterPassportViewModel {
  func updateUserDetails() {
    // TODO: Will implement later
    /*
    if userManager.user != nil {
      if let idvTypeCheck = userManager.user?.idType {
        if idvTypeCheck == idvType.Passport.rawValue {
          if let ssnData = userManager.user?.idNumber {
            passport = ssnData
          }
        }
      }
    }*/
  }
}

// MARK: UI Helpers

extension EnterPassportViewModel {
  func getPassportTypeTitle(type: PassportType) -> String {
    switch type {
    case .international:
      return "passport_type_international".localizedString
    case .us:
      return "passport_type_us".localizedString
    }
  }

  func onSelectedPassportType(type: PassportType) {
    selectedPassport = type
    showPassportTypes.toggle()
  }

  func hidePassportTypes() {
    showPassportTypes = false
  }
}

// MARK: Types

extension EnterPassportViewModel {
  enum SSNInfoError: Error, LocalizedError {
    case invalidSSN

    /// API related custom error title
    var errorDescription: String? {
      switch self {
      case .invalidSSN:
        return "Invalid SSN"
      }
    }
  }

  enum PassportType: String {
    case international = "non_us_passport"
    case us = "us_passport"
  }
}
