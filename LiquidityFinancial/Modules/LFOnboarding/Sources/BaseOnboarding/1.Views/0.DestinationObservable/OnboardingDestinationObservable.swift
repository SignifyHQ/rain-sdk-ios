import Foundation
import SwiftUI
import Factory

// MARK: - DIContainer
public extension Container {
  var onboardingDestinationObservable: Factory<OnboardingDestinationObservable> {
    self { OnboardingDestinationObservable() }.singleton
  }
}

// MARK: - OnboardingDestinationObservable
public final class OnboardingDestinationObservable: ObservableObject {
  @Published public var phoneNumberDestinationView: PhoneNumberNavigation?
  @Published public var verificationCodeDestinationView: VerificationCodeNavigation?
  @Published public var enterSSNDestinationView: EnterSSNNavigation?
  @Published public var personalInformationDestinationView: PersonalInformationNavigation?

  public init() {}
  
  public func clearAllDestinationView() {
    phoneNumberDestinationView = nil
    verificationCodeDestinationView = nil
    enterSSNDestinationView = nil
    personalInformationDestinationView = nil
  }
}
