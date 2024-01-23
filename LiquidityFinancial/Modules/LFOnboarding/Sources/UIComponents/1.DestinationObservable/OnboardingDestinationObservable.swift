import Foundation
import SwiftUI
import Factory

public extension Container {
    var onboardingDestinationObservable: Factory<OnboardingDestinationObservable> {
      self { OnboardingDestinationObservable() }.singleton
    }
}

public final class OnboardingDestinationObservable: ObservableObject {
  public init() {}
  @Published public var enterSSNDestinationView: EnterSSNNavigation?
  @Published public var enterPassportDestinationView: EnterPassportNavigation?
  @Published public var personalInformationDestinationView: PersonalInformationNavigation?
  
  public func clearAllDestinationView() {
    enterSSNDestinationView = nil
    enterPassportDestinationView = nil
    personalInformationDestinationView = nil
  }
  
}
