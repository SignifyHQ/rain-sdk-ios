import Combine
import LFUtilities
import LFLocalizable
import SwiftUI
import Factory
import LFServices

public enum PhoneNumberNavigation {
  case verificationCode(AnyView)
}

@MainActor
public protocol PhoneNumberViewModelProtocol: ObservableObject {
  var isSecretMode: Bool { get set }
  var isLoading: Bool { get set }
  var isDisableButton: Bool { get set }
  var isShowConditions: Bool { get set }
  var phoneNumber: String { get set }
  var toastMessage: String? { get set }
  
  var terms: String { get }
  var esignConsent: String { get }
  var privacyPolicy: String { get }
  
  var destinationObservable: BaseOnboardingDestinationObservable { get }
  init(coordinator: BaseOnboardingDestinationObservable)
  
  func performGetOTP()
  func getURL(tappedString: String) -> String
  func openSupportScreen()
  func onActiveSecretMode()
  func onChangedPhoneNumber(newValue: String)
  func environmentChange(environment: NetworkEnvironment)
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
