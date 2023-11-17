import Combine
import LFUtilities
import LFLocalizable
import SwiftUI
import Factory
import Services
import EnvironmentService

public enum PhoneNumberNavigation {
  case verificationCode(AnyView)
}

@MainActor
public protocol PhoneNumberViewModelProtocol: ObservableObject {
  var isSecretMode: Bool { get set }
  var isLoading: Bool { get set }
  var isButtonDisabled: Bool { get set }
  var isShowConditions: Bool { get set }
  var phoneNumber: String { get set }
  var toastMessage: String? { get set }
  
  var terms: String { get }
  var esignConsent: String { get }
  var privacyPolicy: String { get }
  
  var networkEnvironment: NetworkEnvironment { get set }
  
  var destinationObservable: BaseOnboardingDestinationObservable { get }
  init(coordinator: BaseOnboardingDestinationObservable)
  
  func performGetOTP()
  func getURL(tappedString: String) -> URL?
  func openSupportScreen()
  func onActiveSecretMode()
  func onChangedPhoneNumber(newValue: String)
}

public extension String {
  var reformatPhone: String {
    self
      .replace(string: " ", replacement: "")
      .replace(string: "(", replacement: "")
      .replace(string: ")", replacement: "")
      .replace(string: "-", replacement: "")
      .trimWhitespacesAndNewlines()
  }
}
