import SwiftUI
import LFLocalizable
import Factory
import OnboardingData
import AccountData
import Services

public enum EnterPassportNavigation {
  case address(AnyView)
}

@MainActor
public final class EnterPassportViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  
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
      guard isActionAllowed else { return }
      accountDataManager.update(passport: passport)
    }
  }
  
  public init() {}
  
  func validatePassport() {
    isActionAllowed = isValidPassport(passport)
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
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
      return L10N.Common.passportTypeInternational.localizedString
    case .us:
      return L10N.Common.passportTypeUs.localizedString
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
