import SwiftUI
import LFLocalizable
import Factory
import OnboardingData
import AccountData
import LFServices

@MainActor
final class EnterPassportViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customSupportService) var customSupportService
  
  @Published var isNavigationToAddressView: Bool = false
  @Published var showPassportTypes: Bool = false
  @Published var selectedPassport: PassportType = .international
  @Published var selection: Int?
  @Published var passport: String = "" {
    didSet {
      isAllDataFilled()
      validatePassport()
    }
  }
  @Published var isActionAllowed: Bool = false {
    didSet {
      accountDataManager.update(passport: passport)
    }
  }
  
  func validatePassport() {
    isActionAllowed = isValidPassport(passport)
  }
  
  func openSupportScreen() {
    customSupportService.openSupportScreen()
  }
}

private extension EnterPassportViewModel {
  func isAllDataFilled() {
    isActionAllowed = (!passport.trimWhitespacesAndNewlines().isEmpty)
  }
  
  func isValidPassport(_ passport: String) -> Bool {
    let passportRegEx = "^(?!^0+$)[a-zA-Z0-9]{4,20}$"
    return passport.range(of: passportRegEx, options: .regularExpression, range: nil, locale: nil) != nil
  }
}

// MARK: UI Helpers
extension EnterPassportViewModel {
  func getPassportTypeTitle(type: PassportType) -> String {
    switch type {
    case .international:
      return LFLocalizable.passportTypeInternational.localizedString
    case .us:
      return LFLocalizable.passportTypeUs.localizedString
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
  // swiftlint:disable identifier_name
  enum PassportType: String {
    case international = "non_us_passport"
    case us = "us_passport"
  }
}
