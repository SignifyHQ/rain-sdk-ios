import Foundation
import SwiftUI
import Factory

public extension Container {
    var baseOnboardingNavigations: Factory<BaseOnboardingNavigations> {
      self { BaseOnboardingNavigations() }.singleton
    }
}

public final class BaseOnboardingNavigations: ObservableObject {
  public init() {}
  
  @Published public var verificationDestinationView: VerificationCodeNavigation?
  @Published public var phoneNumberDestinationView: PhoneNumberNavigation?
  @Published public var enterSSNDestinationView: EnterSSNNavigation?
  @Published public var enterPassportDestinationView: EnterPassportNavigation?
  @Published public var personalInformationDestinationView: PersonalInformationNavigation?
}
