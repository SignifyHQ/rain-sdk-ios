import Foundation
import SwiftUI
import Factory

public extension Container {
    var baseOnboardingDestinationObservable: Factory<BaseOnboardingDestinationObservable> {
      self { BaseOnboardingDestinationObservable() }.singleton
    }
}

public final class BaseOnboardingDestinationObservable: ObservableObject {
  public init() {}
  
  @Published public var verificationDestinationView: VerificationCodeNavigation?
  @Published public var phoneNumberDestinationView: PhoneNumberNavigation?
  @Published public var enterSSNDestinationView: EnterSSNNavigation?
  @Published public var enterPassportDestinationView: EnterPassportNavigation?
  @Published public var personalInformationDestinationView: PersonalInformationNavigation?
  
  public func clearAllDestinationView() {
    verificationDestinationView = nil
    phoneNumberDestinationView = nil
    enterSSNDestinationView = nil
    enterPassportDestinationView = nil
    personalInformationDestinationView = nil
  }
  
}
