import Foundation
import SwiftUI

public final class BaseOnboardingNavigations: ObservableObject {
  public init() {}
  
  @Published public var verificationDestinationView: VerificationCodeNavigation?
  @Published public var phoneNumberDestinationView: PhoneNumberNavigation?
}
